#!/bin/sh
# VPNBot Installation Script
# Usage: wget -O- https://your-server/path/to/install.sh | sh -s YOUR_TELEGRAM_BOT_KEY

set -e

BOT_TOKEN="${1:-}"
TAG="${2:-master}"

if [ -z "$BOT_TOKEN" ]; then
    echo "Error: Telegram bot token is required"
    echo "Usage: wget -O- <url>/install.sh | sh -s YOUR_TELEGRAM_BOT_KEY [branch]"
    exit 1
fi

echo "=== VPNBot Installation ==="
echo "Bot Token: ${BOT_TOKEN:0:10}..."
echo "Branch: $TAG"

# Update package list
echo "[1/6] Updating package list..."
apt update

# Install dependencies
echo "[2/6] Installing dependencies..."
apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    make \
    git \
    iptables \
    iproute2 \
    xtables-addons-common \
    xtables-addons-dkms

# Install Docker
echo "[3/6] Installing Docker..."
if ! command -v docker >/dev/null 2>&1; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm -f get-docker.sh
else
    echo "Docker is already installed"
fi

# Clone repository
echo "[4/6] Cloning repository..."
cd /root
if [ -d "vpnbot" ]; then
    echo "Directory vpnbot already exists, removing..."
    rm -rf vpnbot
fi
git clone https://github.com/vpnbot_aio/qwen.git
cd ./qwen
git checkout "$TAG"

# Create config file with bot token
echo "[5/6] Creating configuration..."
cat > ./app/config.php << EOF
<?php

\$c = ['key' => '$BOT_TOKEN'];
EOF

# Create empty override files
touch ./override.env ./docker-compose.override.yml ./config/location.conf ./config/override.conf

# Create .env file if not exists
if [ ! -f ./.env ]; then
    cat > ./.env << EOF
TZ=UTC
IMAGE=mercurykd
EOF
fi

# Start containers
echo "[6/6] Starting containers..."
make u

echo ""
echo "=== Installation Complete ==="
echo "VPNBot has been installed successfully!"
echo "To check status: cd /root/vpnbot && make ps"
echo "To view logs: cd /root/vpnbot && make l"
echo "To restart: cd /root/vpnbot && make r"
echo ""
echo "For auto-start on reboot, run: make cron"
