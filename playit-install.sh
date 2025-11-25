#!/bin/bash

set -e  # dừng script nếu có lỗi

echo "==> Tải khóa GPG..."
sleep 1
curl -SsL https://playit-cloud.github.io/ppa/key.gpg \
    | gpg --dearmor \
    | sudo tee /etc/apt/trusted.gpg.d/playit.gpg >/dev/null
echo "[OK] Đã thêm khóa GPG!"
sleep 1

echo "==> Thêm Playit repo vào hệ thống..."
sleep 1
echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" \
    | sudo tee /etc/apt/sources.list.d/playit-cloud.list
echo "[OK] Đã thêm repo!"
sleep 1

echo "==> Đang cập nhật danh sách gói..."
sleep 2
sudo apt update
echo "[OK] apt update thành công!"
sleep 1

echo "==> Đang cài đặt Playit..."
sleep 2
sudo apt install -y playit
echo "[OK] Cài đặt Playit hoàn tất!"

echo "==> Hoàn tất. Bạn có thể chạy bằng lệnh:"
echo "playit"