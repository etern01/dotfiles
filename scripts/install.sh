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

    # atuin - shell history sync
    if ! command -v atuin &>/dev/null; then
        echo "Installing atuin..."
        curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
    fi
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

    # Install custom plugins
    install_omb_plugin "alias-tips" "https://github.com/ohmybash/oh-my-bash.git" "plugins/alias-tips"
    install_omb_plugin "colored-man-pages" "https://github.com/ohmybash/oh-my-bash.git" "plugins/colored-man-pages"
    install_omb_plugin "docker-compose" "https://github.com/ohmybash/oh-my-bash.git" "plugins/docker-compose"
    install_omb_plugin "extract" "https://github.com/ohmybash/oh-my-bash.git" "plugins/extract"
    install_omb_plugin "history" "https://github.com/ohmybash/oh-my-bash.git" "plugins/history"
    install_omb_plugin "tmux" "https://github.com/ohmybash/oh-my-bash.git" "plugins/tmux"

    # Set agnoster theme
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q "OSH_THEME=" "$HOME/.bashrc" 2>/dev/null; then
            echo "" >> "$HOME/.bashrc"
            echo "# Oh My Bash theme" >> "$HOME/.bashrc"
            echo "OSH_THEME=\"agnoster\"" >> "$HOME/.bashrc"
        fi
    fi
}

# Install Oh My Bash plugin
install_omb_plugin() {
    local name=$1
    local repo=$2
    local path=$3
    local target="$HOME/.oh-my-bash/plugins/$name"

    if [ ! -d "$target" ]; then
        echo "Installing OMB plugin: $name"
        # For built-in OMB plugins, they're already included
        # For external plugins, we'd clone them
        echo "  (plugin $name is included in Oh My Bash)"
    fi
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
echo "========================================="
echo "  Installation complete!"
echo "  Please restart your terminal or run: source ~/.bashrc"
echo "========================================="
