#!/bin/bash
set -e

echo "[*] Updating packages..."
apt update -y && apt upgrade -y

echo "[*] Installing XFCE Desktop (lightweight)..."
DEBIAN_FRONTEND=noninteractive apt install -y xfce4 xfce4-goodies

echo "[*] Installing AnyDesk..."
wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | apt-key add -
echo "deb http://deb.anydesk.com/ all main" > /etc/apt/sources.list.d/anydesk.list
apt update -y
apt install -y anydesk

echo "[*] Enabling AnyDesk service..."
systemctl enable anydesk
systemctl start anydesk

echo ""
echo "✅ Cài đặt hoàn tất!"
echo "👉 Gõ 'anydesk' để lấy ID và kết nối."