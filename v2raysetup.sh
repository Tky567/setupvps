#!/bin/bash
# All-in-One Installer: V2Ray/Xray + VMess + SOCKS5 no-auth & auth
# Fixed listen, TCP+UDP, random port/user/pass
# Author: GPT for Tky

set -e

# Hàm sinh chuỗi ngẫu nhiên
rand_string() {
  LENGTH=$1
  tr -dc A-Za-z0-9 </dev/urandom | head -c $LENGTH
}

# Cài Xray
bash <(curl -fsSL https://github.com/XTLS/Xray-install/raw/main/install-release.sh)

# Sinh UUID cho VMess
UUID=$(cat /proc/sys/kernel/random/uuid)

# Nhập port VMess
read -p "Nhập port VMess (≥10000, để trống sẽ random): " VMESS_PORT
if [ -z "$VMESS_PORT" ]; then
  VMESS_PORT=$(( RANDOM % (65535-10000+1) + 10000 ))
fi

# Nhập port SOCKS5 no-auth
read -p "Nhập port SOCKS5 no-auth (để trống random 1000-65535): " SOCKS_NOAUTH_PORT
if [ -z "$SOCKS_NOAUTH_PORT" ]; then
  SOCKS_NOAUTH_PORT=$(( RANDOM % (65535-1000+1) + 1000 ))
fi

# Nhập port SOCKS5 auth
read -p "Nhập port SOCKS5 auth (để trống random 1000-65535): " SOCKS_AUTH_PORT
if [ -z "$SOCKS_AUTH_PORT" ]; then
  SOCKS_AUTH_PORT=$(( RANDOM % (65535-1000+1) + 1000 ))
fi

# Nhập user/pass cho SOCKS5 auth
read -p "Nhập username SOCKS5 auth (để trống random 6 ký tự): " SOCKS_USER
if [ -z "$SOCKS_USER" ]; then
  SOCKS_USER=$(rand_string 6)
fi

read -p "Nhập password SOCKS5 auth (để trống random 8 ký tự): " SOCKS_PASS
if [ -z "$SOCKS_PASS" ]; then
  SOCKS_PASS=$(rand_string 8)
fi

# Tạo config
cat > /usr/local/etc/xray/config.json <<EOF
{
  "inbounds": [
    {
      "port": $VMESS_PORT,
      "protocol": "vmess",
      "settings": { "clients": [ { "id": "$UUID", "alterId": 0 } ] },
      "streamSettings": { "network": "tcp" }
    },
    {
      "port": $SOCKS_NOAUTH_PORT,
      "listen": "0.0.0.0",
      "protocol": "socks",
      "settings": { "auth": "noauth", "udp": true }
    },
    {
      "port": $SOCKS_AUTH_PORT,
      "listen": "0.0.0.0",
      "protocol": "socks",
      "settings": {
        "auth": "password",
        "accounts": [ { "user": "$SOCKS_USER", "pass": "$SOCKS_PASS" } ],
        "udp": true
      }
    }
  ],
  "outbounds": [ { "protocol": "freedom" } ]
}
EOF

# Mở port firewall
ufw allow $VMESS_PORT/tcp
ufw allow $SOCKS_NOAUTH_PORT/tcp
ufw allow $SOCKS_NOAUTH_PORT/udp
ufw allow $SOCKS_AUTH_PORT/tcp
ufw allow $SOCKS_AUTH_PORT/udp
ufw allow 49152:65535/tcp
ufw allow 49152:65535/udp
ufw reload

# Khởi động và bật Xray
systemctl enable xray
systemctl restart xray

echo "✅ Cài đặt hoàn tất!"
echo "VMess port: $VMESS_PORT, UUID: $UUID"
echo "SOCKS5 no-auth port: $SOCKS_NOAUTH_PORT (TCP+UDP)"
echo "SOCKS5 auth port: $SOCKS_AUTH_PORT (TCP+UDP, user:$SOCKS_USER, pass:$SOCKS_PASS)"