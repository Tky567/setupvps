#!/bin/bash
set -e

echo "🔄 Cập nhật hệ thống và gỡ bỏ mọi GUI cũ + cloudflared..."
apt update -y
apt purge -y xfce4 xfce4-goodies lubuntu-desktop lxqt* ubuntu-desktop gnome-shell kde-plasma-desktop cloudflared || true
apt autoremove -y

echo "💻 Cài Ubuntu MATE + VNC + noVNC..."
apt install -y curl ubuntu-mate-desktop tigervnc-standalone-server novnc websockify

echo "🛠️ Cấu hình VNC để chạy MATE..."
mkdir -p ~/.vnc
cat > ~/.vnc/xstartup <<'EOF'
#!/bin/bash
xrdb $HOME/.Xresources
mate-session &
EOF
chmod +x ~/.vnc/xstartup

echo "🚀 Khởi động lại VNC..."
vncserver -kill :1 >/dev/null 2>&1 || true
rm -rf ~/.vnc/*.log ~/.vnc/*.pid
vncserver :1 -geometry 1280x720 -depth 24

echo "🌐 Khởi động noVNC..."
nohup websockify --web=/usr/share/novnc/ 6080 localhost:5901 > ~/novnc.log 2>&1 &

echo "☁️ Cài lại Cloudflare Tunnel..."
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared
chmod +x /usr/local/bin/cloudflared

echo "🌍 Mở đường hầm với Cloudflare..."
cloudflared tunnel --url http://localhost:6080 --no-autoupdate
