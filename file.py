import os
import discum

# ========== CẤU HÌNH ==========
user_token = "MTMzMjE2MzA1Njk1MTg4NTg1NA.Ga3uOw.2fXLgomXBA-ZaK0mj_RJ3bM99YQeeB21kNk7w8"  # ⚠️ Thay bằng token người dùng thật
target_guild_id = "1279089262108737657"
whitelist_server_ids = ["1141758681449496706"]
# ==============================

# Tạo file nếu chưa có
for fname in ["user_ids.txt", "blacklist.txt"]:
    if not os.path.exists(fname):
        open(fname, "w").close()
        print(f"🆕 Đã tạo {fname}, hãy điền dữ liệu nếu cần và chạy lại.")
        exit()

# Đọc blacklist
with open("blacklist.txt", "r") as f:
    blacklist_ids = set(line.strip() for line in f if line.strip().isdigit())
print(f"📁 Đã nạp {len(blacklist_ids)} ID từ blacklist.txt")

# Hàm quét user ID từ 1 máy chủ
def fetch_all_user_ids(bot, guild_id):
    ids = set()

    @bot.gateway.command
    def handle(resp):
        if resp.raw.get("t") == "READY_SUPPLEMENTAL":
            bot.gateway.fetchMembers(guildID=guild_id, channelID=None, keep="all", wait=1)

        if resp.raw.get("t") == "GUILD_MEMBER_LIST_UPDATE":
            for op in resp.raw["d"]["ops"]:
                if op["op"] == "SYNC":
                    for item in op.get("items", []):
                        if "member" in item and "user" in item["member"]:
                            uid = item["member"]["user"]["id"]
                            ids.add(uid)

        if bot.gateway.finishedMemberFetching(guild_id):
            bot.gateway.removeCommand(handle)
            bot.gateway.close()

    bot.gateway.run()
    return ids

# Tạo client
bot = discum.Client(token=user_token, log=False)
valid_users = []
username_map = {}

@bot.gateway.command
def main(resp):
    if resp.raw.get("t") == "READY_SUPPLEMENTAL":
        print("🛠️ Đang lấy danh sách whitelist...")
        whitelist_ids = set()
        for gid in whitelist_server_ids:
            ids = fetch_all_user_ids(bot, gid)
            whitelist_ids.update(ids)
        print(f"✅ Có {len(whitelist_ids)} user trong server whitelist.")
        bot.whitelist_user_ids = whitelist_ids
        print("🛠️ Đang quét server chính...")
        bot.gateway.fetchMembers(guildID=target_guild_id, channelID=None, keep="all", wait=1)

    if resp.raw.get("t") == "GUILD_MEMBER_LIST_UPDATE":
        for op in resp.raw["d"]["ops"]:
            if op["op"] == "SYNC":
                for item in op.get("items", []):
                    if "member" in item and "user" in item["member"]:
                        user = item["member"]["user"]
                        uid = user["id"]
                        if uid in blacklist_ids:
                            continue
                        if uid not in bot.whitelist_user_ids:
                            continue
                        uname = user["username"]
                        disc = user.get("discriminator", "0000")
                        tag = f"{uname}#{disc}"
                        if uid not in username_map:
                            username_map[uid] = tag
                            valid_users.append(uid)

    if bot.gateway.finishedMemberFetching(target_guild_id):
        bot.gateway.removeCommand(main)
        with open("user_ids.txt", "w", encoding="utf-8") as f:
            for uid in valid_users:
                tag = username_map.get(uid, "unknown")
                f.write(f"{uid} - {tag}\n")
        print(f"✅ Đã lưu {len(valid_users)} user hợp lệ vào user_ids.txt")
        bot.gateway.close()

bot.gateway.run()