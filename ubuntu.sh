#!/bin/bash
set -e

apt update && apt upgrade -y

apt install -y xubuntu-desktop lightdm

apt install -y sudo vim nano net-tools curl wget
passwd root

echo "[Seat:*]
autologin-guest=false
autologin-user=root
autologin-user-timeout=0
" > /etc/lightdm/lightdm.conf.d/50-myconfig.conf

sed -i 's/^\s*#\?\s*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config || true
sed -i 's/^\s*#\?\s*greeter-show-manual-login.*/greeter-show-manual-login=true/' /etc/lightdm/lightdm.conf || true

usermod -s /bin/bash root

echo "[✔] Hoàn tất! Khởi động lại để vào Xubuntu với root mặc định."