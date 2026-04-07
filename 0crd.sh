#!/bin/bash
set -e
trap 'echo "[ERROR] Dừng tại dòng $LINENO"' ERR

echo "=== LXQt + Chrome Remote Desktop installer (attach display :0) ==="
echo "CRD sẽ attach vào display :0 do LightDM quản lý."

CURRENT_USER="$(whoami)"

# Kiểm tra curl
if ! command -v curl >/dev/null 2>&1; then
  echo "[INFO] Cài curl..."
  sudo apt update
  sudo apt install -y curl
fi

sudo apt update

echo "[INFO] Cài Xorg + Xvfb + dependencies..."
sudo apt install -y \
  xorg xvfb xauth dbus-x11 x11-xserver-utils

echo "[INFO] Cài LXQt + LightDM..."
sudo apt install -y \
  lxqt-core lxqt-session openbox \
  lightdm lightdm-gtk-greeter

sudo apt install -y \
  libqt5gui5 libqt5widgets5 libqt5core5a \
  libqt5svg5 qtwayland5 \
  libxcb-xinerama0 libxcb-icccm4 libxcb-keysyms1 libxcb-render-util0 \
  qml-module-qtgraphicaleffects \
  qml-module-qtquick-controls \
  qml-module-qtquick-templates2 \
  qml-module-qtquick-window2

# Tắt Xvfb service thủ công cũ nếu có (LightDM sẽ thay)
if systemctl is-active --quiet xvfb 2>/dev/null; then
  echo "[INFO] Tắt Xvfb service cũ..."
  sudo systemctl stop xvfb || true
  sudo systemctl disable xvfb || true
fi

# ==============================================================
# 1) LightDM: tạo full desktop session trên display :0
#    - autologin → không hiện greeter/màn hình đăng nhập
#    - Xvfb backend → headless server không cần GPU
#    - user-session=lxqt → vào thẳng LXQt
# ==============================================================
echo "[INFO] Cấu hình LightDM autologin trên :0..."

# Buộc openbox làm WM trước khi LightDM start session
mkdir -p "$HOME/.config/lxqt"
cat > "$HOME/.config/lxqt/session.conf" << 'LXQTCONF'
[General]
window_manager=openbox
LXQTCONF

sudo mkdir -p /etc/lightdm/lightdm.conf.d
sudo tee /etc/lightdm/lightdm.conf > /dev/null << EOF
[LightDM]
minimum-display-number=0

[Seat:*]
autologin-user=$CURRENT_USER
autologin-user-timeout=0
user-session=lxqt
greeter-session=lightdm-gtk-greeter
xserver-command=/usr/bin/Xvfb -screen 0 1920x1080x24
EOF

# Cho phép autologin không cần PAM group (tuỳ distro)
sudo tee /etc/lightdm/lightdm.conf.d/50-autologin.conf > /dev/null << EOF
[Seat:*]
autologin-user=$CURRENT_USER
autologin-user-timeout=0
EOF

# Thêm user vào autologin group nếu có
if getent group autologin >/dev/null 2>&1; then
  sudo usermod -aG autologin "$CURRENT_USER"
else
  sudo groupadd -f autologin
  sudo usermod -aG autologin "$CURRENT_USER"
fi

echo "[INFO] Bật LightDM..."
sudo systemctl enable lightdm
sudo systemctl restart lightdm || sudo systemctl start lightdm || true

# Chờ display :0 lên
echo "[INFO] Chờ display :0..."
for i in $(seq 1 20); do
  sleep 1
  if xdpyinfo -display :0 >/dev/null 2>&1; then
    echo "[INFO] Display :0 sẵn sàng (${i}s)"
    break
  fi
  if [ "$i" -eq 20 ]; then
    echo "[WARN] Display :0 chưa lên sau 20s"
    echo "[WARN] Kiểm tra: sudo systemctl status lightdm"
    echo "[WARN] Log: sudo journalctl -u lightdm --no-pager -n 30"
  fi
done

# ==============================================================
# 2) Cài Chrome Remote Desktop
# ==============================================================
echo "[INFO] Tải Chrome Remote Desktop..."
CRD_DEB="/tmp/chrome-remote-desktop.deb"
curl -L -o "$CRD_DEB" \
  https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb

echo "[INFO] Cài Chrome Remote Desktop..."
sudo dpkg -i "$CRD_DEB" || sudo apt-get install -f -y
rm -f "$CRD_DEB"

# ==============================================================
# 3) Patch CRD để attach vào display :0 thay vì tạo display mới
#    CRD daemon (Python) mặc định: FIRST_X_DISPLAY_NUMBER = 20
#    → nó tạo :20, :21... Patch = 0 để dùng :0
#    + Disable hàm launch_x_server để không tạo Xvfb riêng
#      (vì display :0 đã có từ LightDM)
# ==============================================================
CRD_SCRIPT="/opt/google/chrome-remote-desktop/chrome-remote-desktop"

if [ -f "$CRD_SCRIPT" ]; then
  echo "[INFO] Patch CRD daemon để attach display :0..."
  sudo cp "$CRD_SCRIPT" "${CRD_SCRIPT}.bak.$(date +%s)"

  # Patch 1: FIRST_X_DISPLAY_NUMBER = 20 → 0
  sudo sed -i 's/FIRST_X_DISPLAY_NUMBER\s*=\s*20/FIRST_X_DISPLAY_NUMBER = 0/' "$CRD_SCRIPT"

  # Patch 2: Trong hàm launch_x_server / _launch_x_server,
  #   thêm early return nếu display :0 đã chạy.
  #   Tìm dòng "def _launch_x_server" hoặc "def launch_x_server"
  #   và inject check.
  if grep -q "def _launch_x_server" "$CRD_SCRIPT"; then
    FUNC_NAME="_launch_x_server"
  elif grep -q "def launch_x_server" "$CRD_SCRIPT"; then
    FUNC_NAME="launch_x_server"
  else
    FUNC_NAME=""
  fi

  if [ -n "$FUNC_NAME" ]; then
    # Inject đoạn code sau dòng "def <func>(self...):"
    # Nếu display :0 đã tồn tại → set self._display = 0 và return
    sudo python3 << PATCHEOF
import re

with open("$CRD_SCRIPT", "r") as f:
    content = f.read()

# Tìm dòng def _launch_x_server(self...) hoặc def launch_x_server(self...)
pattern = r'(def ${FUNC_NAME}\(self[^)]*\):\s*\n)'
match = re.search(pattern, content)
if match:
    inject = '''    # [PATCHED] Attach vào display :0 nếu đã có
    import subprocess
    try:
        subprocess.check_call(["xdpyinfo", "-display", ":0"],
                              stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        self._display = 0
        return
    except Exception:
        pass
'''
    insert_pos = match.end()
    content = content[:insert_pos] + inject + content[insert_pos:]
    with open("$CRD_SCRIPT", "w") as f:
        f.write(content)
    print("[PATCH] Injected display :0 attach vào $FUNC_NAME")
else:
    print("[WARN] Không tìm thấy $FUNC_NAME, bỏ qua patch")
PATCHEOF
  fi

  echo "[INFO] Patch xong. File gốc đã backup."
else
  echo "[WARN] Không tìm thấy $CRD_SCRIPT — bỏ qua patch."
fi

# ==============================================================
# 4) Session file — fallback nếu CRD vẫn tạo display mới
#    Trường hợp attach :0 thành công → file này không chạy
#    Trường hợp CRD tạo display riêng → vẫn khởi LXQt
# ==============================================================
echo "[INFO] Tạo CRD session file..."
sudo tee /etc/chrome-remote-desktop-session > /dev/null << 'SESSIONEOF'
#!/bin/bash
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=LXQt

if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
  eval $(dbus-launch --sh-syntax --exit-with-session)
fi

mkdir -p "$HOME/.config/lxqt"
cat > "$HOME/.config/lxqt/session.conf" << 'LXQTCONF'
[General]
window_manager=openbox
LXQTCONF

exec startlxqt
SESSIONEOF
sudo chmod +x /etc/chrome-remote-desktop-session

# Đảm bảo user thuộc group chrome-remote-desktop
if ! id -nG "$CURRENT_USER" | grep -qw chrome-remote-desktop; then
  echo "[INFO] Thêm $CURRENT_USER vào group chrome-remote-desktop..."
  sudo usermod -aG chrome-remote-desktop "$CURRENT_USER"
fi

echo "[INFO] Restart CRD service..."
sudo systemctl restart chrome-remote-desktop@"$CURRENT_USER" || true

echo ""
echo "=== DONE ==="
echo "LightDM → display :0 (LXQt + openbox, autologin)"
echo "CRD đã patch → attach vào display :0 (mirror màn hình thật)"
echo ""
echo "Bước tiếp: vào https://remotedesktop.google.com/headless lấy lệnh đăng ký CRD."
echo "Remote vào sẽ thấy cùng desktop đang chạy trên :0."
