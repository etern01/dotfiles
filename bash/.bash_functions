# ~/.bash_functions - Diagnostic and utility functions
# Organized by category

# ============================================
# System diagnostics
# ============================================

# Quick system health check
health-check() {
    echo "============================================="
    echo "  System Health Check: $(hostname)"
    echo "  Date: $(date)"
    echo "============================================="
    echo ""

    echo "--- Uptime & Load ---"
    uptime
    echo ""

    echo "--- Memory ---"
    free -h
    echo ""

    echo "--- Disk Usage ---"
    df -h | grep -E '^/|Filesystem'
    echo ""

    echo "--- Top 5 CPU Processes ---"
    ps aux --sort=-%cpu | head -6
    echo ""

    echo "--- Top 5 Memory Processes ---"
    ps aux --sort=-%mem | head -6
    echo ""

    echo "--- Network Connections Summary ---"
    ss -s
    echo ""

    echo "--- Docker Status ---"
    if command -v docker &>/dev/null; then
        docker info --format 'Containers: {{.Containers}} (Running: {{.ContainersRunning}}, Stopped: {{.ContainersStopped}})' 2>/dev/null || echo "Docker not running"
    else
        echo "Docker not installed"
    fi
    echo ""

    echo "--- Last 5 System Reboots ---"
    last reboot | head -5 2>/dev/null || echo "No reboot history"
    echo ""

    echo "============================================="
}

# ============================================
# Network diagnostics
# ============================================

# Check what's listening on a port
port-check() {
    local port=${1:?Usage: port-check <port>}
    echo "Checking port $port..."
    echo ""
    echo "--- Listening ---"
    ss -tlnp | grep ":$port" || echo "Nothing listening on port $port"
    echo ""
    echo "--- Established connections ---"
    ss -tnp | grep ":$port" || echo "No established connections on port $port"
}

# Show top connections by IP
top-connections() {
    local limit=${1:-20}
    echo "Top $limit IPs by connection count:"
    ss -tn | awk 'NR>1 {print $5}' | cut -d: -f1 | sort | uniq -c | sort -rn | head -n "$limit"
}

# Check SSL certificate
cert-check() {
    local domain=${1:?Usage: cert-check <domain> [port]}
    local port=${2:-443}
    echo "Checking SSL certificate for $domain:$port..."
    echo ""
    echo | openssl s_client -servername "$domain" -connect "$domain:$port" 2>/dev/null | openssl x509 -noout -dates -subject -issuer 2>/dev/null || echo "Failed to retrieve certificate"
}

# Full DNS lookup
dns-lookup() {
    local domain=${1:?Usage: dns-lookup <domain>}
    echo "=== A Records ==="
    dig +short A "$domain"
    echo ""
    echo "=== AAAA Records ==="
    dig +short AAAA "$domain"
    echo ""
    echo "=== MX Records ==="
    dig +short MX "$domain"
    echo ""
    echo "=== TXT Records ==="
    dig +short TXT "$domain"
    echo ""
    echo "=== NS Records ==="
    dig +short NS "$domain"
}

# ============================================
# Disk & File diagnostics
# ============================================

# Show disk usage by directory
disk-usage() {
    local dir=${1:-.}
    local depth=${2:-1}
    echo "Disk usage in $dir (top 20):"
    du -sh "$dir"/* 2>/dev/null | sort -rh | head -20
}

# Find large files
find-large-files() {
    local size=${1:-100M}
    local dir=${2:-/}
    echo "Finding files larger than $size in $dir..."
    find "$dir" -type f -size +${size} -exec ls -lh {} \; 2>/dev/null | awk '{print $5, $9}' | sort -rh
}

# Show inode usage
inode-usage() {
    echo "Inode usage by filesystem:"
    df -i | grep -E '^/|Filesystem'
    echo ""
    echo "Top directories by inode count (in current dir):"
    for d in */; do
        count=$(find "$d" -maxdepth 1 2>/dev/null | wc -l)
        echo "$count $d"
    done | sort -rn | head -10
}

# ============================================
# Docker utilities
# ============================================

# Docker cleanup
docker-cleanup() {
    echo "Docker cleanup..."
    echo ""

    echo "--- Stopped containers ---"
    docker ps -a --filter "status=exited" --format "{{.Names}}" | while read -r container; do
        echo "Removing: $container"
        docker rm "$container"
    done
    echo ""

    echo "--- Dangling images ---"
    docker images --filter "dangling=true" --format "{{.ID}}" | while read -r image; do
        echo "Removing: $image"
        docker rmi "$image"
    done
    echo ""

    echo "--- Unused volumes ---"
    docker volume prune -f
    echo ""

    echo "--- Unused networks ---"
    docker network prune -f
    echo ""

    echo "Cleanup complete!"
}

# Show container resource usage
docker-stats() {
    docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
}

# Follow docker container logs
dlog() {
    local container=${1:?Usage: dlog <container>}
    docker logs -f --tail 100 "$container"
}

# ============================================
# Process diagnostics
# ============================================

# Find process by name
proc-find() {
    local name=${1:?Usage: proc-find <name>}
    ps aux | grep -v grep | grep "$name"
}

# Show open files for a process
proc-files() {
    local pid=${1:?Usage: proc-files <pid>}
    lsof -p "$pid" | head -50
}

# Trace system calls
proc-trace() {
    local pid=${1:?Usage: proc-trace <pid>}
    sudo strace -p "$pid" -c
}

# ============================================
# Log utilities
# ============================================

# Follow service logs
log-follow() {
    local service=${1:?Usage: log-follow <service>}
    if command -v journalctl &>/dev/null; then
        journalctl -u "$service" -f
    else
        tail -f /var/log/"$service"/*.log 2>/dev/null || echo "No logs found for $service"
    fi
}

# Search logs for pattern
log-search() {
    local pattern=${1:?Usage: log-search <pattern> [file]}
    local file=${2:-/var/log/syslog}
    grep -i "$pattern" "$file" | tail -50
}

# ============================================
# SSH utilities
# ============================================

# SSH with custom key
ssh-key() {
    local key=${1:?Usage: ssh-key <key-path> <user@host>}
    local target=${2:?Usage: ssh-key <key-path> <user@host>}
    ssh -i "$key" "$target"
}

# ============================================
# Misc utilities
# ============================================

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract any archive
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick file size
filesize() {
    local file=${1:?Usage: filesize <file>}
    ls -lh "$file" | awk '{print $5}'
}

# Generate random password
genpass() {
    local length=${1:-16}
    openssl rand -base64 48 | cut -c1-"$length"
}

# Base64 encode/decode
b64enc() { echo -n "$1" | base64; }
b64dec() { echo -n "$1" | base64 -d; }

# JSON pretty print
json() {
    if [ -t 0 ]; then
        cat "$1" | jq .
    else
        jq .
    fi
}
