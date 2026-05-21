# Dotfiles - Usage Guide

Comprehensive guide for using the unified DevOps environment.

## Table of Contents

- [Installation](#installation)
- [Oh My Bash](#oh-my-bash)
- [Vim Editor](#vim-editor)
- [Tmux Terminal Multiplexer](#tmux-terminal-multiplexer)
- [SSH Configuration](#ssh-configuration)
- [Utilities](#utilities)
- [Diagnostic Tools](#diagnostic-tools)
- [Docker Utilities](#docker-utilities)
- [Network Tools](#network-tools)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)

---

## Installation

### Quick Install (Bootstrap)
```bash
git clone https://github.com/etern01/dotfiles.git ~/.dotfiles
~/.dotfiles/scripts/install.sh
```

### One-liner for new hosts
```bash
curl -sL https://raw.githubusercontent.com/etern01/dotfiles/master/scripts/install.sh | bash
```

### Ansible Deployment
```bash
vim ~/.dotfiles/ansible/inventory.ini
ansible-playbook -i ~/.dotfiles/ansible/inventory.ini ~/.dotfiles/ansible/playbook.yml
```

### Update
```bash
cd ~/.dotfiles && git pull && source ~/.bashrc
```

---

## Oh My Bash

### Theme: Agnoster

Powerline-style prompt with color-coded segments:

```
 etern0@server  ~/project   main 
$
```

**Segments:**
| Segment | Color | Condition |
|---|---|---|
| `✘ code` | Red | Exit code non-zero |
| `user@host` | Blue (green if root) | Non-default user or SSH |
| `~/path` | Cyan | Always shown |
| ` branch` | Green | Git repo, clean |
| ` branch ✚` | Yellow | Git repo, dirty |
| `PROD/STAGE/DEV` | Red/Yellow/Cyan | Auto-detected from hostname |

**Root vs Non-root:**
- Non-root: Blue user segment, `$` prompt
- Root: Yellow user segment, `#` prompt

### Environment Detection

Auto-detected from hostname:
- `*prod*` → `[PROD]` (red)
- `*staging*` or `*stage*` → `[STAGE]` (yellow)
- `*dev*` → `[DEV]` (cyan)

Or set manually:
```bash
export ENV_TYPE=PROD
```

### Nerd Fonts

For proper powerline symbols (, , ✚), install a Nerd Font:

```bash
# Download and install JetBrains Mono Nerd Font
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -fLo "JetBrainsMonoNerdFont.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip JetBrainsMonoNerdFont.zip
fc-cache -fv
```

Then set your terminal font to `JetBrainsMono Nerd Font`.

### Plugins

| Plugin | Description | Key Features |
|---|---|---|
| `git` | Git aliases | `gs`, `gp`, `gl`, `gc`, `glog` |
| `docker` | Docker completion | Auto-complete for docker commands |
| `docker-compose` | Compose aliases | `dcu`, `dcd`, `dcl` |
| `fzf` | Fuzzy finder | `Ctrl+R` history, `Ctrl+T` files |
| `sudo` | Double Esc for sudo | `Esc Esc` → prepends `sudo` |
| `alias-tips` | Alias hints | Shows `Tip: gs` for `git status` |
| `colored-man-pages` | Color man pages | `man ls` with colors |
| `extract` | Extract archives | `x archive.tar.gz` |
| `history` | Better history | Enhanced `Ctrl+R` search |
| `tmux` | Tmux aliases | `ta`, `tl`, `tn`, `tk` |

### Key Bindings

**Fuzzy finder:**
```
Ctrl+R      # Search command history
Ctrl+T      # Search files
Alt+C       # Search directories
```

**Sudo:**
```
ls /root    # Permission denied
Esc Esc     # sudo ls /root
```

**Extract:**
```bash
x archive.tar.gz    # Extract any archive
x archive.zip
x archive.bz2
```

---

## Vim Editor

### Basic Usage

```bash
vim file.txt        # Open file
vim .               # Open NERDTree
vim +42 file.txt    # Open at line 42
```

### Key Mappings

**Leader key:** `,`

| Key | Action |
|---|---|
| `,w` | Save |
| `,q` | Quit |
| `,ev` | Edit vimrc |
| `,sv` | Source vimrc |
| `,n` | Toggle NERDTree |
| `,y` | Copy to clipboard (visual) |
| `,p` | Paste from clipboard |
| `Alt+j/k` | Move line down/up |

### Plugins

- **NERDTree** - File browser
- **fzf.vim** - Fuzzy finder (`:Files`, `:Rg`, `:Buffers`)
- **vim-fugitive** - Git (`:Gstatus`, `:Gcommit`, `:Gdiff`)
- **vim-polyglot** - Syntax for 100+ languages
- **vim-surround** - Easy quotes/brackets
- **vim-commentary** - `gcc` to toggle comments
- **auto-pairs** - Auto-close brackets

---

## Tmux Terminal Multiplexer

### Basic Usage

```bash
tmux                # New session
tmux a              # Attach to last session
tmux a -t name      # Attach to named session
tmux ls             # List sessions
```

**Auto-start:** Tmux auto-starts on SSH login (session: `main`)

### Key Bindings

**Prefix:** `Ctrl+a`

| Key | Action |
|---|---|
| `Prefix + d` | Detach |
| `Prefix + c` | New window |
| `Prefix + \|` | Split vertical |
| `Prefix + -` | Split horizontal |
| `Prefix + h/j/k/l` | Navigate panes |
| `Prefix + [` | Copy mode |
| `Prefix + z` | Zoom pane |
| `Prefix + r` | Reload config |

---

## SSH Configuration

### Connection Multiplexing

Faster subsequent connections — reuses TCP socket:

```bash
# First connection - creates socket
ssh server1

# Second connection - instant
ssh server1
```

Socket location: `~/.ssh/sockets/`

### Example Config

```ssh-config
Host prod-*
    User deploy
    IdentityFile ~/.ssh/id_ed25519_prod

Host bastion
    HostName bastion.example.com
    IdentityFile ~/.ssh/id_ed25519

Host internal-*
    ProxyJump bastion
    IdentityFile ~/.ssh/id_ed25519
```

---

## Utilities

### zoxide — Smart cd

Remembers frequently visited directories:

```bash
z project       # cd to most recent "project" dir
z -l            # List tracked directories
z -i            # Interactive selection
```

### yq — YAML processor

Like `jq` but for YAML:

```bash
# Read value
yq '.services.web.image' docker-compose.yml

# Update value
yq -i '.services.web.image = "nginx:latest"' docker-compose.yml

# Convert YAML to JSON
yq -o=json docker-compose.yml

# Merge files
yq eval-all '. as $item ireduce ({}; . * $item)' file1.yml file2.yml
```

### httpie — Modern HTTP client

Better than curl for APIs:

```bash
# GET request
http GET https://api.example.com/users

# POST with JSON
http POST https://api.example.com/users name=John age=30

# With auth
http -a user:pass https://api.example.com/secret

# Download file
http -d https://example.com/file.zip
```

### lazygit — Terminal UI for git

```bash
lazygit           # Open TUI
```

**Key bindings:**
| Key | Action |
|---|---|
| `c` | Commit |
| `p` | Push |
| `P` | Pull |
| `s` | Stage file |
| `d` | View diff |
| `?` | Help |

### btop — Resource monitor

Beautiful replacement for htop:

```bash
btop              # Start monitor
```

**Key bindings:**
| Key | Action |
|---|---|
| `m` | Cycle modules |
| `p` | Pin process |
| `k` | Kill process |
| `f` | Follow process |
| `q` | Quit |

### atuin — Shell history sync

Syncs history across machines with search:

```bash
atuin register    # Create account
atuin login       # Login
atuin sync        # Sync history

# After setup, Ctrl+R uses atuin search
```

**Search features:**
- Full-text search
- Filter by directory, exit code, duration
- Sync across all your machines

---

## Diagnostic Tools

### System Health Check

```bash
health-check
```

Shows: uptime, memory, disk, top processes, network, docker status.

### Process Diagnostics

```bash
proc-find nginx       # Find process
proc-files 1234       # Open files for PID
proc-trace 1234       # strace PID
```

### Disk Diagnostics

```bash
disk-usage /var       # Top directories by size
find-large-files 100M /   # Files > 100M
inode-usage           # Inode usage
```

### Quick Checks

```bash
mem                   # Memory usage
disk                  # Disk usage
top10cpu              # Top 10 CPU processes
top10mem              # Top 10 memory processes
iotop                 # IO usage (sudo)
```

---

## Docker Utilities

### Basic Commands

```bash
d                   # docker
dc                  # docker compose
dps                 # docker ps (formatted)
dpsa                # docker ps -a
dlogs <container>   # docker logs -f --tail 100
dexec <container>   # docker exec -it
```

### Docker Compose

```bash
dcu                 # docker compose up -d
dcd                 # docker compose down
dcl                 # docker compose logs -f
dcr                 # docker compose restart
dcps                # docker compose ps
```

### Maintenance

```bash
docker-stats        # Container resource usage
docker-cleanup      # Remove unused resources
dlog <container>    # Follow container logs
```

---

## Network Tools

### Connection Analysis

```bash
ports               # sudo netstat -tlnp
listen              # ss -tlnp
connections         # Connection count by state
established         # Established connections
top-connections     # Top IPs by count
port-check 8080     # Check specific port
```

### DNS & SSL

```bash
dns example.com                 # dig +short
dns-lookup example.com          # Full lookup
cert-check example.com          # SSL certificate
```

### Network Diagnostics

```bash
myip                # Public IP
ping example.com    # 5 packets
mtr example.com     # Traceroute + ping
nmap -sV host       # Service scan
```

### Log Utilities

```bash
log-follow nginx    # Follow service logs
log-search "error"  # Search logs
jctl                # journalctl -xe
jf                  # journalctl -f
```

---

## Customization

### Add New Aliases

Edit `~/.bash_aliases`:
```bash
alias mycommand='some --long --command'
```

Reload:
```bash
source ~/.bashrc
```

### Add New Functions

Edit `~/.bash_functions`:
```bash
my-function() {
    echo "Hello from $1"
}
```

### Change Oh My Bash Theme

Edit `~/.bashrc`:
```bash
OSH_THEME="powerline"  # or any OMB theme
```

Available themes: `agnoster`, `powerline`, `bashstylish`, `es`, `fresh`, and more in `~/.oh-my-bash/themes/`.

### Add New Plugins

Edit `~/.bashrc`:
```bash
plugins=(
    git
    docker
    # add new plugin name here
)
```

### Add New Hosts

Edit `~/.ssh/config`:
```ssh-config
Host myserver
    HostName 192.168.1.100
    User admin
    IdentityFile ~/.ssh/id_ed25519
```

---

## Troubleshooting

### Vim Plugins Not Loading

```bash
ls ~/.vim/autoload/plug.vim
mkdir -p ~/.vim/autoload
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall +qall
```

### Tmux Not Starting

```bash
tmux kill-server
rm -rf /tmp/tmux-*
```

### Sudo Plugin Not Working

Fallback bind is in `.bash_aliases`. If still not working:
```bash
bind '"\e\e": "\C-asudo \C-m"'
```

### Prompt Symbols Not Showing

Install Nerd Fonts (see [Nerd Fonts](#nerd-fonts) section).

### SSH Connection Issues

```bash
ssh -v user@host
ssh-add -l
ssh-add ~/.ssh/id_ed25519
```

---

## Quick Reference

### Most Used Commands

```bash
# System
health-check          # Full system check
btop                  # Resource monitor
disk                  # Disk usage

# Navigation
z project             # Smart cd
fzf                   # Fuzzy find files (Ctrl+T)

# Docker
dps                   # Running containers
dlogs <name>          # View logs
dcu                   # Start compose
dcd                   # Stop compose

# Network
port-check <port>     # Check port
connections           # Connection summary
cert-check <domain>   # SSL cert

# Git
gs                    # Status
gp                    # Push
gl                    # Pull
lazygit               # TUI for git

# YAML
yq '.key' file.yml    # Read YAML value

# HTTP
http GET url          # HTTP request

# Tmux
tmux a                # Attach
Ctrl+a, d             # Detach
Ctrl+a, \|            # Split vertical
Ctrl+a, -             # Split horizontal
```

### File Locations

```
~/.dotfiles/
├── bash/
│   ├── .bashrc           # Main config (Oh My Bash)
│   ├── .bash_aliases     # Aliases
│   ├── .bash_functions   # Functions
│   └── .bash_prompt      # Legacy (not used with OMB)
├── vim/
│   └── .vimrc            # Vim config
├── tmux/
│   └── .tmux.conf        # Tmux config
├── ssh/
│   └── config            # SSH config
├── ansible/
│   ├── playbook.yml      # Ansible deployment
│   └── inventory.ini     # Host inventory
├── scripts/
│   └── install.sh        # Bootstrap script
└── USAGE.md              # This guide
```
