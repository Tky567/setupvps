#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "[✓] Đang cấp quyền truy cập bộ nhớ..."
termux-setup-storage

echo "[✓] Đang cập nhật hệ thống..."
yes | pkg update && yes | pkg upgrade

echo "[✓] Đang cài các gói cần thiết..."
pkg install -y wget unzip python git

echo "[✓] Đang cài thư viện Python..."
pip install -U pip
pip install -U discord.py python-dotenv

echo "[✓] Đang tải bot về..."
wget -c https://github.com/Tky567/setupvps/raw/refs/heads/main/discord-bot.zip -O discord-bot.zip

echo "[✓] Đang giải nén..."
unzip -o discord-bot.zip

echo "[✓] Đang chạy bot..."
cd /sdcard/download/
python free.py
