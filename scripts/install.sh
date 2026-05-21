#!/usr/bin/env bash
set -euo pipefail

# Dotfiles bootstrap script
# Usage: curl -sL https://your-dotfiles/install.sh | bash
#    or: ./install.sh

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

echo "========================================="
echo "  Dotfiles Bootstrap"
echo "========================================="

# Detect OS
if [ -f /etc/debian_version ]; then
    OS="debian"
elif [ -f /etc/redhat-release ]; then
    OS="rhel"
elif [ -f /etc/alpine-release ]; then
    OS="alpine"
else
    OS="unknown"
fi

echo "Detected OS: $OS"

# Install packages
install_packages() {
    echo ""
    echo "Installing packages..."

    case "$OS" in
        debian|ubuntu)
            sudo apt-get update
            sudo apt-get install -y \
                htop btop tmux vim jq tree curl wget rsync \
                dnsutils net-tools iproute2 nmap ncat mtr socat \
                tcpdump iftop nethogs \
                strace lsof iotop sysstat \
                ncdu lnav fzf ripgrep fd-find bat grc \
                zoxide httpie \
                git bash-completion \
                ansible
            ;;
        rhel|rocky|centos)
            sudo dnf install -y \
                htop tmux vim jq tree curl wget rsync \
                bind-utils iproute nmap ncat mtr socat \
                tcpdump iftop nethogs \
                strace lsof iotop sysstat \
                ncdu fzf ripgrep fd-find bat \
                git bash-completion \
                ansible
            ;;
        alpine)
            sudo apk add \
                htop tmux vim jq tree curl wget rsync \
                bind-tools iproute2 nmap ncat mtr socat \
                tcpdump iftop nethogs \
                strace lsof iotop sysstat \
                ncdu fzf ripgrep fd bat \
                git bash-completion
            ;;
        *)
            echo "Unsupported OS: $OS"
            exit 1
            ;;
    esac
}

# Create symlinks
create_symlinks() {
    echo ""
    echo "Creating symlinks..."

    local files=(
        "bash/.bashrc"
        "bash/.bash_aliases"
        "bash/.bash_functions"
        "bash/.bash_prompt"
        "vim/.vimrc"
        "tmux/.tmux.conf"
    )

    for file in "${files[@]}"; do
        local src="$DOTFILES_DIR/$file"
        local dst="$HOME/$(basename $file)"

        if [ -L "$dst" ] || [ -f "$dst" ]; then
            echo "Backing up $dst -> ${dst}.bak"
            mv "$dst" "${dst}.bak" 2>/dev/null || true
        fi

        ln -sf "$src" "$dst"
        echo "Linked: $file -> $dst"
    done

    # SSH config (only if doesn't exist)
    if [ ! -f "$HOME/.ssh/config" ]; then
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
        ln -sf "$DOTFILES_DIR/ssh/config" "$HOME/.ssh/config"
        echo "Linked: ssh/config -> ~/.ssh/config"
    else
        echo "SSH config already exists, skipping"
    fi
}

# Install additional tools from GitHub releases
install_tools() {
    echo ""
    echo "Installing additional tools..."

    # yq - YAML processor
    if ! command -v yq &>/dev/null; then
        echo "Installing yq..."
        curl -sL https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -o /tmp/yq
        sudo mv /tmp/yq /usr/local/bin/yq
        sudo chmod +x /usr/local/bin/yq
    fi

    # lazygit - terminal UI for git
    if ! command -v lazygit &>/dev/null; then
        echo "Installing lazygit..."
        local lazygit_version=$(curl -sL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | jq -r '.tag_name | ltrimstr("v")')
        curl -sL "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${lazygit_version}_Linux_x86_64.tar.gz" | tar xz -C /tmp
        sudo mv /tmp/lazygit /usr/local/bin/lazygit
        sudo chmod +x /usr/local/bin/lazygit
    fi
}

# Install vim plugins
install_vim_plugins() {
    echo ""
    echo "Installing vim plugins..."

    # Install vim-plug if not present
    if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
        echo "Installing vim-plug..."
        mkdir -p "$HOME/.vim/autoload"
        curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi

    # Install plugins
    vim +PlugInstall +qall 2>/dev/null || true
}

# Install Oh My Bash
install_oh_my_bash() {
    echo ""
    echo "Installing Oh My Bash..."

    if [ ! -d "$HOME/.oh-my-bash" ]; then
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" "" --unattended
        echo "Oh My Bash installed!"
    else
        echo "Oh My Bash already installed"
    fi

    # Set agnoster theme
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q "OSH_THEME=" "$HOME/.bashrc" 2>/dev/null; then
            echo "" >> "$HOME/.bashrc"
            echo "# Oh My Bash theme" >> "$HOME/.bashrc"
            echo "OSH_THEME=\"agnoster\"" >> "$HOME/.bashrc"
        fi
    fi
}

# Install Oh My Bash custom plugins
install_omb_custom_plugins() {
    echo ""
    echo "Installing Oh My Bash custom plugins..."

    local custom_dir="$HOME/.oh-my-bash/custom/plugins"
    mkdir -p "$custom_dir"

    # Copy custom plugins from dotfiles repository
    if [ -d "$DOTFILES_DIR/plugins" ]; then
        for plugin_dir in "$DOTFILES_DIR/plugins/"*/; do
            local plugin_name=$(basename "$plugin_dir")
            local target_dir="$custom_dir/$plugin_name"
            mkdir -p "$target_dir"
            cp "$plugin_dir"/*.plugin.sh "$target_dir"/ 2>/dev/null
            echo "  Installed: $plugin_name"
        done
        echo "Custom plugins installed!"
    else
        echo "No custom plugins found in $DOTFILES_DIR/plugins"
    fi
}

# Remove atuin if installed (conflicts with bash prompt)
remove_atuin() {
    echo ""
    echo "Removing atuin (conflicts with prompt)..."

    # Remove atuin init from .bashrc
    if [ -f "$HOME/.bashrc" ]; then
        sed -i '/atuin init/d' "$HOME/.bashrc" 2>/dev/null
    fi

    # Remove atuin binary and config
    if [ -d "$HOME/.atuin" ]; then
        rm -rf "$HOME/.atuin"
    fi

    # Remove atuin from PATH
    if [ -d "$HOME/.atuin/bin" ]; then
        rm -rf "$HOME/.atuin/bin"
    fi

    echo "Atuin removed."
}

# Main
echo ""
echo "Step 1: Installing packages..."
install_packages

echo ""
echo "Step 2: Installing additional tools..."
install_tools

echo ""
echo "Step 3: Creating symlinks..."
create_symlinks

echo ""
echo "Step 4: Installing vim plugins..."
install_vim_plugins

echo ""
echo "Step 5: Installing Oh My Bash..."
install_oh_my_bash

echo ""
echo "Step 6: Installing Oh My Bash custom plugins..."
install_omb_custom_plugins

echo ""
echo "Step 7: Removing atuin (conflicts with prompt)..."
remove_atuin

echo ""
echo "========================================="
echo "  Installation complete!"
echo "  Please restart your terminal or run: source ~/.bashrc"
echo "========================================="
