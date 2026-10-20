#!/usr/bin/env bash
# Basic hardening for the Ubuntu 24.04 VPN server.
# Run on the server with: sudo bash hardening.sh
# Read it before you run it. Don't run scripts you haven't read.

set -euo pipefail

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root: sudo bash $0"
  exit 1
fi

echo "[1/4] Updating packages..."
apt update && apt upgrade -y

echo "[2/4] Installing fail2ban and unattended-upgrades..."
apt install -y fail2ban unattended-upgrades

echo "[3/4] Configuring fail2ban for SSH..."
cat > /etc/fail2ban/jail.local << 'JAIL'
[sshd]
enabled  = true
port     = ssh
maxretry = 5
findtime = 10m
bantime  = 1h
JAIL
systemctl enable --now fail2ban
systemctl restart fail2ban

echo "[4/4] Enabling automatic security updates..."
dpkg-reconfigure -f noninteractive unattended-upgrades

echo
echo "SSH settings check (we only report, we don't change anything):"
sshd -T | grep -E "^(passwordauthentication|permitrootlogin|pubkeyauthentication)" || true

echo
echo "Done. Useful checks:"
echo "  sudo fail2ban-client status sshd"
echo "  systemctl status unattended-upgrades"
