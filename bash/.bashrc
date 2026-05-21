# ~/.bashrc - Main configuration with Oh My Bash
# Sourced by interactive bash shells

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# ============================================
# History settings
# ============================================
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT="%F %T "
shopt -s histappend

# ============================================
# Shell options
# ============================================
shopt -s cdspell          # Auto-correct cd typos
shopt -s dirspell         # Spell check on cd
shopt -s autocd           # Enter directory name to cd
shopt -s checkwinsize     # Check window size after each command
shopt -s globstar         # Enable ** globbing
shopt -s extglob          # Enable extended globbing

# ============================================
# Path additions
# ============================================
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# ============================================
# Editor
# ============================================
export EDITOR=vim
export VISUAL=vim

# ============================================
# Less options
# ============================================
export LESS="-R -i -M -S -x4"

# ============================================
# direnv (if installed)
# ============================================
if command -v direnv &>/dev/null; then
    eval "$(direnv hook bash)"
fi

# ============================================
# Load aliases
# ============================================
source ~/.bash_aliases

# ============================================
# Load functions
# ============================================
source ~/.bash_functions

# ============================================
# Auto-completion
# ============================================
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# Docker completion
if command -v docker &>/dev/null; then
    if [ -f /usr/share/bash-completion/completions/docker ]; then
        . /usr/share/bash-completion/completions/docker
    fi
fi

# Git completion
if command -v git &>/dev/null; then
    if [ -f /usr/share/bash-completion/completions/git ]; then
        . /usr/share/bash-completion/completions/git
    fi
fi

# ============================================
# SSH agent forwarding
# ============================================
if [ -z "$SSH_AUTH_SOCK" ]; then
    if [ -S "$HOME/.ssh/agent.sock" ]; then
        export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
    fi
fi

# ============================================
# Colorized output (grc)
# ============================================
if command -v grc &>/dev/null; then
    . /usr/share/grc/grc.bashrc
fi

# ============================================
# Welcome message (first login)
# ============================================
if [ -z "$DOTFILES_WELCOMED" ]; then
    export DOTFILES_WELCOMED=1
    echo "============================================="
    echo "  Welcome to $(hostname)"
    echo "  OS: $(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'\"' -f2)"
    echo "  Uptime: $(uptime -p 2>/dev/null || uptime)"
    echo "============================================="
fi

# ============================================
# Auto-start tmux on SSH login
# ============================================
if command -v tmux &>/dev/null && [ -z "$TMUX" ] && [ -n "$SSH_CLIENT" ]; then
    tmux attach -t main 2>/dev/null || tmux new-session -s main
    exit
fi

# ============================================
# Oh My Bash
# ============================================
if [ -f "$HOME/.oh-my-bash/oh-my-bash.sh" ]; then
    OSH="$HOME/.oh-my-bash"
    OSH_THEME="agnoster"

    # Plugins
    plugins=(
        git
        docker
        docker-compose
        fzf
        sudo
        alias-tips
        colored-man-pages
        extract
        history
        tmux
    )

    source "$OSH/oh-my-bash.sh"
fi
