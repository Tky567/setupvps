#!/bin/bash
# All-in-One Installer: Xray/V2Ray + VMess + SOCKS5 (no-auth + auth)
# Author: GPT for Tky

set -e

# Cài Xray
bash <(curl -fsSL https://github.com/XTLS/Xray-install/raw/main/install-release.sh)

# Sinh UUID
UUID=$(cat /proc/sys/kernel/random/uuid)

# Chọn port VMess listen
VMESS_PORT=12345

# Chọn port SOCKS5
SOCKS_NOAUTH_PORT=1080
SOCKS_AUTH_PORT=1081

# Tạo config
cat > /usr/local/etc/xray/config.json <<EOF
{
  "inbounds": [
    {
      "port": $VMESS_PORT,
      "protocol": "vmess",
      "settings": {
        "clients": [
          { "id": "$UUID", "alterId": 0 }
        ]
      },
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
        "accounts": [ { "user": "test", "pass": "1234" } ],
        "udp": true
      }
    }
  ],
  "outbounds": [
    { "protocol": "freedom" }
  ]
}
EOF

# Mở port firewall
ufw allow $VMESS_PORT/tcp
ufw allow $SOCKS_NOAUTH_PORT/tcp
ufw allow $SOCKS_AUTH_PORT/tcp
ufw allow 49152:65535/tcp
ufw allow 49152:65535/udp
ufw reload

# Restart dịch vụ
systemctl enable xray
systemctl restart xray

echo "✅ Cài đặt hoàn tất!"
echo "VMess port: $VMESS_PORT, UUID: $UUID"
echo "SOCKS5 no-auth port: $SOCKS_NOAUTH_PORT"
echo "SOCKS5 auth port: $SOCKS_AUTH_PORT (user:test, pass:1234)"