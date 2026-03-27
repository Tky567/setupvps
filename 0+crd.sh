#!/bin/bash
set -e
trap 'echo "[ERROR] Dừng tại dòng $LINENO"' ERR

echo "=== LXQt + Chrome Remote Desktop installer (display :0) ==="

# Kiểm tra curl
if ! command -v curl >/dev/null 2>&1; then
  echo "[INFO] Cài curl..."
  sudo apt update
  sudo apt install -y curl
fi

sudo apt update

echo "[INFO] Cài Xorg + dependencies..."
sudo apt install -y \
  xorg xvfb xauth dbus-x11

echo "[INFO] Cài LXQt..."
sudo apt install -y \
  lxqt-core lxqt-session openbox

sudo apt install -y \
  libqt5gui5 libqt5widgets5 libqt5core5a \
  libqt5svg5 qtwayland5 \
  libxcb-xinerama0 libxcb-icccm4 libxcb-keysyms1 libxcb-render-util0 \
  qml-module-qtgraphicaleffects \
  qml-module-qtquick-controls \
  qml-module-qtquick-templates2 \
  qml-module-qtquick-window2

# Khởi động Xvfb trên :0 nếu chưa có X server
if ! xdpyinfo -display :0 >/dev/null 2>&1; then
  echo "[INFO] Không tìm thấy display :0, khởi động Xvfb..."
  Xvfb :0 -screen 0 1920x1080x24 &
  sleep 2
  echo "[INFO] Xvfb đang chạy trên :0"
else
  echo "[INFO] Display :0 đã sẵn sàng"
fi

# Đảm bảo Xvfb tự start khi reboot
sudo tee /etc/systemd/system/xvfb.service > /dev/null << 'EOF'
[Unit]
Description=Xvfb virtual display :0
After=network.target

[Service]
ExecStart=/usr/bin/Xvfb :0 -screen 0 1920x1080x24
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable xvfb
sudo systemctl start xvfb || true

echo "[INFO] Tải Chrome Remote Desktop..."
CRD_DEB="/tmp/chrome-remote-desktop.deb"
curl -L -o "$CRD_DEB" \
  https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb

echo "[INFO] Cài Chrome Remote Desktop..."
sudo dpkg -i "$CRD_DEB" || sudo apt-get install -f -y
rm -f "$CRD_DEB"

# Session file trỏ thẳng vào :0
sudo tee /etc/chrome-remote-desktop-session > /dev/null << 'EOF'
#!/bin/bash
export DISPLAY=:0
export XDG_SESSION_TYPE=x11
exec /usr/bin/startlxqt
EOF
sudo chmod +x /etc/chrome-remote-desktop-session

# Backup config LXQt cũ nếu có
if [ -d "$HOME/.config/lxqt" ]; then
  echo "[INFO] Backup config LXQt cũ..."
  mv "$HOME/.config/lxqt" "$HOME/.config/lxqt.bak.$(date +%s)"
fi

echo "[INFO] Khởi động lại CRD service..."
sudo systemctl restart chrome-remote-desktop@$USER || true

echo ""
echo "=== DONE ==="
echo "Display :0 đang chạy. CRD sẽ kết nối vào :0 thay vì tạo display mới."