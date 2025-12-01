#!/bin/bash

set -e  # dừng nếu có lỗi

# =============================
# 3. Kiểm tra gpg
# =============================
echo "==> Kiểm tra gpg..."
if ! command -v gpg >/dev/null 2>&1; then
    echo "gpg chưa có — đang cài đặt..."
    sudo apt update
    sudo apt install -y gnupg
fi
echo "[OK] gpg đã sẵn sàng!"
sleep 1

# =============================
# 4. Tải key GPG
# =============================
echo "==> Tải key GPG của Playit..."
curl -SsL -o playit.key https://playit-cloud.github.io/ppa/key.gpg
echo "[OK] Đã tải key!"
sleep 1

# =============================
# 5. Chuyển key sang dạng gpg
# =============================
echo "==> Chuyển định dạng key..."
gpg --dearmor playit.key
sudo mv playit.key.gpg /etc/apt/trusted.gpg.d/playit.gpg
rm playit.key
echo "[OK] Key đã được cài!"
sleep 1

# =============================
# 6. Thêm repository Playit
# =============================
echo "==> Thêm Playit repository..."
echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" \
    | sudo tee /etc/apt/sources.list.d/playit-cloud.list
sleep 1

# =============================
# 7. apt update có retry 3 lần
# =============================
echo "==> Đang chạy apt update (tối đa 3 lần)..."

for i in {1..3}; do
    if sudo apt update; then
        echo "[OK] apt update thành công!"
        break
    else
        echo "⚠️ Lỗi apt update — thử lại ($i/3)..."
        sleep 3
    fi

    # Nếu thử 3 lần vẫn lỗi thì thoát
    if [ "$i" -eq 3 ]; then
        echo "❌ apt update thất bại sau 3 lần thử."
        exit 1
    fi
done

sleep 1

# =============================
# 8. Cài đặt Playit
# =============================
echo "==> Cài đặt Playit..."
sudo apt install -y playit
echo "[OK] Playit đã cài đặt xong!"
sleep 1

# =============================
# 9. Hoàn tất
# =============================
echo ""
echo "==============================="
echo "   🎉 CÀI ĐẶT HOÀN TẤT! 🎉"
echo "Chạy Playit bằng lệnh:"
echo "   playit"
echo "==============================="