#!/bin/bash

echo "📦 Đang cập nhật và cài Python + Git + Curl..."
sudo apt update && sudo apt install -y python3 python3-pip git curl

echo "🐍 Đang nâng cấp pip và cài discum..."
pip3 install --upgrade pip
pip3 uninstall -y discum
pip3 install git+https://github.com/Merubokkusu/Discord-S.C.U.M.git --upgrade

echo "📁 Đang tạo thư mục ~/discord-tool..."
mkdir -p ~/discord-tool
cd ~/discord-tool

echo "📥 Đang tải file.py từ GitHub..."
curl -sL -o file.py "https://raw.githubusercontent.com/Tky567/setupvps/refs/heads/main/file.py"

touch user_ids.txt
touch blacklist.txt

echo "✅ Đã hoàn tất cài đặt!"
echo "📌 Bây giờ hãy sửa 'file.py' để thay token:"
echo "  nano ~/discord-tool/file.py"
echo "➡️ Sau đó chạy bằng:"
echo "  python3 file.py"
