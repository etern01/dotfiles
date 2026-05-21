# Dotfiles - Unified DevOps Environment

Centralized, portable development and administration environment for all servers.

## Quick Start

### Option 1: Bootstrap script (no Ansible)

```bash
# Clone repository
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles

# Run installer
~/.dotfiles/scripts/install.sh

# Or one-liner for new hosts
curl -sL https://raw.githubusercontent.com/yourusername/dotfiles/main/scripts/install.sh | bash
```

### Option 2: Ansible playbook

```bash
# Edit inventory
vim ansible/inventory.ini

# Run playbook
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml

# Run on specific host
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --limit vm01
```

## Structure

```
├── ansible/
│   ├── playbook.yml           # Ansible deployment
│   └── inventory.ini          # Host inventory
├── bash/
│   ├── .bashrc                # Main config
│   ├── .bash_aliases          # Command aliases
│   ├── .bash_functions        # Diagnostic functions
│   └── .bash_prompt           # Custom prompt
├── vim/
│   └── .vimrc                 # Vim configuration
├── tmux/
│   └── .tmux.conf             # Tmux configuration
├── ssh/
│   └── config                 # SSH config template
├── scripts/
│   └── install.sh             # Bootstrap script
├── .gitignore
└── README.md
```

## Features

### Bash
- **Prompt**: `user@host:path (git-branch) [ENV] $` with color-coded environments
- **History**: Shared between sessions, 10000 entries, timestamps
- **Aliases**: Docker, git, system monitoring, network diagnostics
- **Functions**: `health-check`, `port-check`, `disk-usage`, `cert-check`, `top-connections`, `docker-cleanup`, and more

### Vim
- vim-plug plugin manager
- NERDTree file browser
- FZF fuzzy finder
- Git integration (fugitive)
- Syntax highlighting for YAML, JSON, Dockerfile, Terraform, Go

### Tmux
- Ctrl-a prefix
- Mouse support
- Vim-style pane navigation
- Status bar with hostname

### SSH
- Connection multiplexing (faster reconnections)
- Config templates for different environments

## Environment Detection

The prompt automatically detects environment based on hostname:
- `*prod*` → Red `[PROD]`
- `*staging*` or `*stage*` → Yellow `[STAGE]`
- `*dev*` → Cyan `[DEV]`

Or set manually: `export ENV_TYPE=PROD`

## Installed Packages

### Base
htop, tmux, vim, jq, tree, curl, wget, rsync, git, bash-completion

### Network
dnsutils, net-tools, iproute2, nmap, ncat, mtr, socat, tcpdump, iftop, nethogs

### Diagnostics
strace, lsof, iotop, sysstat, ncdu, lnav, fzf, ripgrep, fd-find, bat

### Docker
docker-ce, docker-compose-plugin

## Customization

### Add new aliases
Edit `bash/.bash_aliases` and run `source ~/.bashrc`

### Add new functions
Edit `bash/.bash_functions` and run `source ~/.bashrc`

### Change prompt colors
Edit `bash/.bash_prompt`

### Add new hosts
Edit `ansible/inventory.ini` and `ssh/config`

## Security Notes

- **NEVER** commit SSH keys to this repository
- **NEVER** commit `.env` files with secrets
- Use `.env.local` for local secrets (in .gitignore)
- SSH keys should be in `~/.ssh/` with 600 permissions
