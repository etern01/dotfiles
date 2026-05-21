# ~/.bash_aliases - Command aliases
# Organized by category

# ============================================
# Navigation & Listing
# ============================================
alias ll='ls -alhF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias lt='ls -lt --color=auto | head -20'
alias lsd='ls -d */ --color=auto'

# ============================================
# File operations
# ============================================
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias mkdir='mkdir -pv'

# Safety: confirm destructive operations
alias rmrf='rm -rf'

# ============================================
# System monitoring
# ============================================
alias mem='free -h'
alias disk='df -h'
alias top10cpu='ps aux --sort=-%cpu | head -11'
alias top10mem='ps aux --sort=-%mem | head -11'
alias cputop='htop'
alias memhog='ps aux --sort=-%mem | head -20'
alias cpuhog='ps aux --sort=-%cpu | head -20'
alias load='uptime'
alias iotop='sudo iotop -o'

# ============================================
# Network
# ============================================
alias ports='sudo netstat -tlnp'
alias connections='netstat -an | awk "/^tcp/ {print \$6}" | sort | uniq -c | sort -rn'
alias listen='ss -tlnp'
alias established='ss -tnp state established'
alias dns='dig +short'
alias myip='curl -s ifconfig.me'
alias ping='ping -c 5'

# ============================================
# Docker
# ============================================
alias d='docker'
alias dc='docker compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dpsa='docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dlogs='docker logs -f --tail 100'
alias dexec='docker exec -it'
alias dstop='docker stop'
alias drm='docker rm'
alias drmi='docker rmi'
alias dimages='docker images'
alias dvolumes='docker volume ls'
alias dnetworks='docker network ls'

# Docker compose shortcuts
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'
alias dcr='docker compose restart'
alias dcps='docker compose ps'

# ============================================
# Git
# ============================================
alias g='git'
alias gs='git status'
alias gp='git push'
alias gl='git pull'
alias gc='git commit -m'
alias gco='git checkout'
alias gb='git branch'
alias gd='git diff'
alias glog='git log --oneline --graph --decorate -20'
alias gloga='git log --oneline --graph --decorate --all -20'

# ============================================
# Vim
# ============================================
alias v='vim'
alias vi='vim'

# ============================================
# Tmux
# ============================================
alias t='tmux'
alias ta='tmux attach -t'
alias tls='tmux ls'
alias tn='tmux new-session -s'
alias tk='tmux kill-session -t'

# ============================================
# Quick edits
# ============================================
alias vb='vim ~/.bashrc'
alias va='vim ~/.bash_aliases'
alias vf='vim ~/.bash_functions'
alias vp='vim ~/.bash_prompt'
alias sb='source ~/.bashrc'

# ============================================
# Misc
# ============================================
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# Calendar
alias cal='cal -m'

# System info
alias sysinfo='uname -a'

# Journalctl shortcuts
alias jctl='journalctl -xe'
alias jf='journalctl -f'
alias jk='journalctl -k'
