#!/bin/bash
set -e

echo "=== LXQt + Chrome Remote Desktop installer ==="
if ! command -v curl >/dev/null 2>&1; then
  echo "[INFO] curl not found, installing..."
  sudo apt update
  sudo apt install -y curl
fi
sudo apt update
sudo apt install -y \
xorg xvfb xauth dbus-x11
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
CRD_DEB="/tmp/chrome-remote-desktop.deb"
echo "[INFO] Downloading Chrome Remote Desktop..."
curl -L -o "$CRD_DEB" \
https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
echo "[INFO] Installing Chrome Remote Desktop..."
sudo apt install -y "$CRD_DEB"
sudo tee /etc/chrome-remote-desktop-session > /dev/null << 'EOF'
#!/bin/bash
export XDG_SESSION_TYPE=x11
exec /usr/bin/startlxqt
EOF
sudo chmod +x /etc/chrome-remote-desktop-session
if [ -d "$HOME/.config/lxqt" ]; then
  mv "$HOME/.config/lxqt" "$HOME/.config/lxqt.bak.$(date +%s)"
fi
sudo systemctl restart chrome-remote-desktop@$USER || true
echo "=== DONE ==="