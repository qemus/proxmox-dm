#!/usr/bin/env bash
set -Eeuo pipefail

# Docker environment variables
: "${DEBUG:="N"}"         # Disable debugging
: "${PASSWORD:="root"}"   # Default password

# Helper functions

info () { printf "%b%s%b" "\E[1;34m❯ \E[1;36m" "${1:-}" "\E[0m\n"; }
error () { printf "%b%s%b" "\E[1;31m❯ " "ERROR: ${1:-}" "\E[0m\n" >&2; }
warn () { printf "%b%s%b" "\E[1;31m❯ " "Warning: ${1:-}" "\E[0m\n" >&2; }

# Check environment
[ "$(id -u)" -ne "0" ] && error "Script must be executed with root privileges." && exit 11
[ ! -f "/usr/local/bin/entrypoint.sh" ] && error "Script must be run inside the container!" && exit 12

# Display version number
info "Starting Proxmox Datacenter Manager for Docker v$(</etc/version)..."
info "For support visit https://github.com/dockur/proxmox-dm"
echo ""

# Update password for root
printf 'root:%s\n' "$PASSWORD" | chpasswd

# Fix permissions

dir="/etc/proxmox-datacenter-manager"
user=$(grep '^User=' /lib/systemd/system/proxmox-datacenter-api.service | cut -d= -f2)

mkdir -p "$dir"
chmod 1770 "$dir"
chown "$user:$user" "$dir"

dir="/var/lib/proxmox-datacenter-manager"
mkdir -p "$dir"
chown "$user:$user" "$dir"

exec "$@"
