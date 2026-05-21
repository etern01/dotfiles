# Dotfiles - Usage Guide

Comprehensive guide for using the unified DevOps environment.

## Table of Contents

- [Installation](#installation)
- [Bash Shell](#bash-shell)
- [Vim Editor](#vim-editor)
- [Tmux Terminal Multiplexer](#tmux-terminal-multiplexer)
- [SSH Configuration](#ssh-configuration)
- [Diagnostic Tools](#diagnostic-tools)
- [Docker Utilities](#docker-utilities)
- [Network Tools](#network-tools)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)

---

## Installation

### Quick Install (Bootstrap)
```bash
# Clone repository
git clone https://github.com/etern01/dotfiles.git ~/.dotfiles

# Run installer
~/.dotfiles/scripts/install.sh

# Or one-liner for new hosts
curl -sL https://raw.githubusercontent.com/etern01/dotfiles/master/scripts/install.sh | bash
```

### Ansible Deployment
```bash
# Edit inventory
vim ~/.dotfiles/ansible/inventory.ini

# Deploy to all hosts
ansible-playbook -i ~/.dotfiles/ansible/inventory.ini ~/.dotfiles/ansible/playbook.yml

# Deploy to specific host
ansible-playbook -i ~/.dotfiles/ansible/inventory.ini ~/.dotfiles/ansible/playbook.yml --limit vm01
```

### Update
```bash
cd ~/.dotfiles && git pull
source ~/.bashrc
```

---

## Bash Shell

### Prompt

The prompt uses Powerline-style segments with color-coded information:

```
✘  etern0@server  ~/dev/project   main  [PROD]
$
```

**Segments:**
| Segment | Description | Colors |
|---|---|---|
| `✘` | Exit code (if non-zero) | Red background |
| `user@host` | Current user and hostname | Green (normal) / Red (root) |
| `~/path` | Current directory | Blue background |
| ` branch` | Git branch (if in repo) | Yellow background |
| `[ENV]` | Environment indicator | Red (PROD) / Yellow (STAGE) / Cyan (DEV) |

**Root vs Non-root:**
- Non-root: Green user segment, `$` prompt symbol
- Root: Red user segment, `#` prompt symbol

**Environment Detection:**
Auto-detected from hostname patterns:
- `*prod*` → `[PROD]` (red)
- `*staging*` or `*stage*` → `[STAGE]` (yellow)
- `*dev*` → `[DEV]` (cyan)

Or set manually:
```bash
export ENV_TYPE=PROD
```

### History

**Features:**
- 10,000 entries (20,000 in file)
- Shared between all sessions
- Timestamps: `2024-01-15 14:30:22 command`
- No duplicates
- Ignores commands starting with space

**Search history:**
```bash
Ctrl+R          # Reverse search
Ctrl+G          # Exit search
!!              # Repeat last command
!n              # Repeat command #n from history
!string         # Repeat last command starting with string
```

### Navigation

**Aliases:**
```bash
ll              # ls -alhF (detailed listing)
la              # ls -A (all files)
lt              # ls -lt | head -20 (recent files)
lsd             # ls -d */ (directories only)
..              # cd ..
...             # cd ../..
....            # cd ../../..
-               # cd - (previous directory)
```

**Auto-cd:**
```bash
# Just type directory name to cd into it
~/projects      # Equivalent to: cd ~/projects
```

**Spell correction:**
```bash
cd /etc/ngnix   # Auto-corrects to /etc/nginx
```

### Quick Access

**Edit configs:**
```bash
vb              # Edit .bashrc
va              # Edit .bash_aliases
vf              # Edit .bash_functions
vp              # Edit .bash_prompt
sb              # Source .bashrc (reload)
```

---

## Vim Editor

### Basic Usage

**Open files:**
```bash
vim file.txt        # Open file
vim .               # Open NERDTree in current directory
vim +42 file.txt    # Open at line 42
vim -O file1 file2  # Open files in vertical split
```

### Key Mappings

**Leader key:** `,`

**File operations:**
| Key | Action |
|---|---|
| `,w` | Save file |
| `,q` | Quit |
| `,ev` | Edit vimrc |
| `,sv` | Source vimrc |
| `,s` | Search and replace in file |
| `,h` | Clear search highlight |

**Clipboard:**
| Key | Action |
|---|---|
| `,y` | Copy to system clipboard (visual mode) |
| `,Y` | Copy line to system clipboard |
| `,p` | Paste from system clipboard |

**Navigation:**
| Key | Action |
|---|---|
| `Alt+j` | Move line down |
| `Alt+k` | Move line up |
| `Ctrl+n` | Toggle NERDTree |

### Plugins

**Installed plugins:**
- **NERDTree** - File browser
- **fzf.vim** - Fuzzy file finder
- **vim-fugitive** - Git integration
- **vim-polyglot** - Syntax highlighting for 100+ languages
- **vim-go** - Go language support
- **vim-surround** - Easy quote/bracket manipulation
- **vim-commentary** - Easy commenting (`gcc` to toggle)
- **auto-pairs** - Auto-close brackets/quotes

**NERDTree:**
```
,n              # Toggle file browser
?               # Show help
o               # Open file/directory
go              # Preview file
t               # Open in new tab
T               # Open in new tab (stay)
m               # Show file menu (add/delete/move)
```

**fzf.vim:**
```
:Files          # Fuzzy find files
:Rg             # Fuzzy search file contents
:Buffers        # Fuzzy find open buffers
:History        # Fuzzy find recent files
:GFiles         # Fuzzy find git files
```

**vim-fugitive:**
```
:Gstatus        # Git status
:Gcommit        # Git commit
:Gpush          # Git push
:Gpull          # Git pull
:Gdiff          # Git diff
:Glog           # Git log
:Gblame         # Git blame
```

### File Type Settings

| File Type | Indent |
|---|---|
| YAML | 2 spaces |
| JSON | 2 spaces |
| Dockerfile | 2 spaces |
| Terraform | 2 spaces |
| Python | 4 spaces |
| Shell | 4 spaces |

---

## Tmux Terminal Multiplexer

### Basic Usage

**Start tmux:**
```bash
tmux                # New session
tmux new -s name    # New named session
tmux a              # Attach to last session
tmux a -t name      # Attach to named session
tmux ls             # List sessions
```

**Auto-start:** Tmux auto-starts on SSH login (session name: `main`)

### Key Bindings

**Prefix:** `Ctrl+a`

**Sessions:**
| Key | Action |
|---|---|
| `Prefix + d` | Detach from session |
| `Prefix + s` | Session list |
| `Prefix + $` | Rename session |
| `Prefix + n` | New session |

**Windows:**
| Key | Action |
|---|---|
| `Prefix + c` | New window |
| `Prefix + w` | Window list |
| `Prefix + ,` | Rename window |
| `Prefix + &` | Kill window |
| `Prefix + n/p` | Next/previous window |
| `Prefix + 0-9` | Switch to window # |

**Panes:**
| Key | Action |
|---|---|
| `Prefix + \|` | Split vertically |
| `Prefix + -` | Split horizontally |
| `Prefix + h/j/k/l` | Navigate panes (vim-style) |
| `Prefix + x` | Kill pane |
| `Prefix + z` | Toggle zoom pane |
| `Prefix + !` | Break pane to window |
| `Prefix + {/}` | Swap pane up/down |
| `Prefix + Space` | Rotate panes |

**Resize panes:**
| Key | Action |
|---|---|
| `Prefix + H/J/K/L` | Resize pane (hold for repeat) |

**Copy mode:**
| Key | Action |
|---|---|
| `Prefix + [` | Enter copy mode |
| `v` | Begin selection |
| `y` | Copy selection |
| `Escape` | Cancel selection |
| `q` | Exit copy mode |

**Other:**
| Key | Action |
|---|---|
| `Prefix + r` | Reload config |
| `Prefix + S` | Toggle synchronized panes |
| `Prefix + m` | Toggle mouse mode |

### Useful Workflows

**Persistent sessions:**
```bash
# Create session for project
tmux new -s monitoring

# Detach (session keeps running)
Ctrl+a, d

# Reattach later
tmux a -t monitoring
```

**Split workflow:**
```bash
# Vertical split (left/right)
Ctrl+a, |

# Horizontal split (top/bottom)
Ctrl+a, -

# Navigate between panes
Ctrl+a, h/j/k/l
```

---

## SSH Configuration

### Setup

**Create SSH keys:**
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

**Edit config:**
```bash
vim ~/.ssh/config
```

### Connection Multiplexing

**Benefits:**
- Faster subsequent connections
- Reuses existing TCP connection
- No need to re-authenticate

**How it works:**
```bash
# First connection - creates socket
ssh server1

# Second connection - reuses socket (instant)
ssh server1
scp file server1:
```

**Socket location:** `~/.ssh/sockets/`

### Example Config

```ssh-config
# Production servers
Host prod-*
    User deploy
    IdentityFile ~/.ssh/id_ed25519_prod
    Port 22

# Staging servers
Host stage-*
    User deploy
    IdentityFile ~/.ssh/id_ed25519_stage
    Port 22

# Jump host / Bastion
Host bastion
    User admin
    HostName bastion.example.com
    IdentityFile ~/.ssh/id_ed25519

# Hosts behind bastion
Host internal-*
    User admin
    ProxyJump bastion
    IdentityFile ~/.ssh/id_ed25519
```

### Usage

```bash
# Connect to server
ssh prod-web01

# Copy file
scp file.txt prod-web01:/tmp/

# Port forwarding
ssh -L 8080:localhost:80 prod-web01

# Through bastion
ssh internal-db01
```

---

## Diagnostic Tools

### System Health Check

```bash
health-check
```

**Output:**
- Uptime & load average
- Memory usage
- Disk usage
- Top CPU processes
- Top memory processes
- Network connections summary
- Docker status
- Recent reboots

### Process Diagnostics

```bash
# Find process
proc-find nginx

# Show open files for process
proc-files 1234

# Trace system calls
proc-trace 1234
```

### Disk Diagnostics

```bash
# Disk usage by directory
disk-usage /var

# Find large files (>100M)
find-large-files 100M /

# Inode usage
inode-usage
```

### Memory & CPU

```bash
# Quick checks
mem                 # Memory usage
disk                # Disk usage
top10cpu            # Top 10 CPU processes
top10mem            # Top 10 memory processes
memhog              # Top 20 memory consumers
cpuhog              # Top 20 CPU consumers
load                # Load average
iotop               # IO usage (sudo)
```

---

## Docker Utilities

### Basic Commands

```bash
# Short aliases
d                   # docker
dc                  # docker compose
dps                 # docker ps (formatted)
dpsa                # docker ps -a (formatted)
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
# Show container resource usage
docker-stats

# Cleanup unused resources
docker-cleanup

# Follow container logs
dlog <container>
```

---

## Network Tools

### Connection Analysis

```bash
# Check what's listening
ports               # sudo netstat -tlnp
listen              # ss -tlnp

# Connection summary
connections         # Count by state
established         # Established connections
top-connections     # Top IPs by connection count

# Check specific port
port-check 8080
```

### DNS & SSL

```bash
# DNS lookup
dns example.com     # dig +short
dns-lookup example.com  # Full lookup (A, AAAA, MX, TXT, NS)

# SSL certificate check
cert-check example.com
cert-check example.com 443
```

### Network Diagnostics

```bash
# My public IP
myip

# Ping (5 packets)
ping example.com

# MTR (traceroute + ping)
mtr example.com

# Nmap scan
nmap -sV example.com
```

### Log Utilities

```bash
# Follow service logs
log-follow nginx

# Search logs
log-search "error" /var/log/syslog

# Journalctl shortcuts
jctl                # journalctl -xe
jf                  # journalctl -f
jk                  # journalctl -k
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

Reload:
```bash
source ~/.bashrc
```

### Change Prompt Colors

Edit `~/.bash_prompt`:
```bash
# Available colors:
RED, GREEN, YELLOW, BLUE, MAGENTA, CYAN, WHITE, GRAY

# Background colors:
BG_RED, BG_GREEN, BG_BLUE, BG_YELLOW, BG_MAGENTA, BG_CYAN, BG_GRAY
```

### Add New Hosts

Edit `~/.ssh/config`:
```ssh-config
Host myserver
    HostName 192.168.1.100
    User admin
    IdentityFile ~/.ssh/id_ed25519
```

### Environment Detection

Add hostname patterns in `~/.bash_prompt`:
```bash
detect_env() {
    # ... existing patterns ...
    elif [[ "$HOSTNAME" == *"custom"* ]]; then
        echo "CUSTOM"
    fi
}
```

And add color in `build_prompt()`:
```bash
CUSTOM)
    env_bg=$BG_MAGENTA
    env_segment="\[$env_bg\]\[$env_fg\] $env \[$RESET\]"
    ;;
```

---

## Troubleshooting

### Vim Plugins Not Loading

```bash
# Check vim-plug installation
ls ~/.vim/autoload/plug.vim

# Reinstall vim-plug
mkdir -p ~/.vim/autoload
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install plugins
vim +PlugInstall +qall
```

### Tmux Not Starting

```bash
# Check tmux installation
which tmux

# Kill all tmux sessions
tmux kill-server

# Remove stale sockets
rm -rf /tmp/tmux-*
```

### SSH Connection Issues

```bash
# Test connection
ssh -v user@host

# Check SSH agent
ssh-add -l

# Add key to agent
ssh-add ~/.ssh/id_ed25519
```

### Prompt Not Showing Colors

```bash
# Check TERM variable
echo $TERM

# Should be: xterm-256color or screen-256color
export TERM=xterm-256color
```

### Git Branch Not Showing in Prompt

```bash
# Check if in git repository
git status

# Check if git is installed
which git
```

---

## Quick Reference

### Most Used Commands

```bash
# System
health-check          # Full system check
htop                  # Process monitor
disk                  # Disk usage

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
glog                  # Log

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
│   ├── .bashrc           # Main config
│   ├── .bash_aliases     # Aliases
│   ├── .bash_functions   # Functions
│   └── .bash_prompt      # Prompt config
├── vim/
│   └── .vimrc            # Vim config
├── tmux/
│   └── .tmux.conf        # Tmux config
├── ssh/
│   └── config            # SSH config
└── scripts/
    └── install.sh        # Bootstrap script
```
