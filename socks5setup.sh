#!/bin/bash
set -e

read -p "Nhập username cho proxy [proxyuser]: " PROXY_USER
read -s -p "Nhập password cho proxy [proxypass]: " PROXY_PASS
echo
read -p "Nhập port cho proxy [1080]: " PROXY_PORT

PROXY_USER=${PROXY_USER:-proxyuser}
PROXY_PASS=${PROXY_PASS:-proxypass}
PROXY_PORT=${PROXY_PORT:-1080}

echo "[+] Cài Dante server..."
apt update -y
apt install dante-server -y

echo "[+] Tạo user $PROXY_USER ..."
if id "$PROXY_USER" &>/dev/null; then
    echo "User $PROXY_USER đã tồn tại."
else
    useradd -m -s /bin/false "$PROXY_USER"
fi
echo "$PROXY_USER:$PROXY_PASS" | chpasswd

IFACE=$(ip route get 1 | awk '{print $5; exit}')

cat > /etc/danted.conf <<EOF
logoutput: stderr
internal: $IFACE port = $PROXY_PORT
external: $IFACE

method: username
user.notprivileged: nobody

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect disconnect error
}
pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    protocol: tcp udp
}
EOF

ufw allow $PROXY_PORT/tcp || true

systemctl restart danted
systemctl enable danted

IP=$(curl -s ifconfig.me || echo "$IP")
echo
echo "======================================"
echo " SOCKS5 Proxy đã sẵn sàng!"
echo " Địa chỉ:  $IP:$PROXY_PORT"
echo " User:     $PROXY_USER"
echo " Password: $PROXY_PASS"
echo "======================================"