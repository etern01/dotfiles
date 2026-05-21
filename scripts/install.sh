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
                htop tmux vim jq tree curl wget rsync \
                dnsutils net-tools iproute2 nmap ncat mtr socat \
                tcpdump iftop nethogs \
                strace lsof iotop sysstat \
                ncdu lnav fzf ripgrep fd-find bat grc \
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

# Main
echo ""
echo "Step 1: Installing packages..."
install_packages

echo ""
echo "Step 2: Creating symlinks..."
create_symlinks

echo ""
echo "Step 3: Installing vim plugins..."
install_vim_plugins

echo ""
echo "========================================="
echo "  Installation complete!"
echo "  Please restart your terminal or run: source ~/.bashrc"
echo "========================================="
