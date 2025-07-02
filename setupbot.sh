#!/data/data/com.termux/files/usr/bin/bash
set -e

# Chỉ cấp quyền nếu chưa có thư mục ~/storage
if [ ! -d "$HOME/storage" ]; then
    echo "[✓] Đang cấp quyền truy cập bộ nhớ..."
    termux-setup-storage
fi

echo "[✓] Đang cập nhật hệ thống..."
yes | pkg update && yes | pkg upgrade

echo "[✓] Đang cài các gói cần thiết..."
pkg install -y wget unzip python git

echo "[✓] Đang cài thư viện Python..."
pkg install python-pip -y
pip install -U discord.py python-dotenv requests

echo "[✓] Đang tải bot về..."
cd /storage/emulated/0/Download/
wget -c https://github.com/Tky567/setupvps/raw/refs/heads/tky/discord-bot.zip -O discord-bot.zip

echo "[✓] Đang giải nén..."
unzip -o discord-bot.zip

echo "[✓] Đang chạy bot..."
cd /sdcard/download/discord-bot/
python free.py
