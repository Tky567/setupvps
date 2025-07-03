import os
import discord
import requests
from discord.ext import commands
from dotenv import load_dotenv

# Load file cấu hình
load_dotenv(dotenv_path="config.env")

BOT_TOKEN = os.getenv("BOT_TOKEN")
WEBHOOK_URL = os.getenv("WEBHOOK_URL")

# Bot không cần channel_id nếu chỉ dùng webhook
intents = discord.Intents.default()
intents.message_content = True
bot = commands.Bot(command_prefix="!", intents=intents)

@bot.command()
async def join(ctx, roblox_username: str, jobid: str):
    roblox_username = roblox_username.strip()
    jobid = jobid.strip()

    # Nội dung gửi qua webhook
    content = f"{roblox_username}: {jobid}"

    try:
        response = requests.post(WEBHOOK_URL, json={"content": content})
        if response.status_code == 204:
            await ctx.send(f"✅ Đã gửi JobId `{jobid}` cho `{roblox_username}`.")
        else:
            await ctx.send(f"❌ Lỗi gửi JobId. Status: {response.status_code}")
    except Exception as e:
        await ctx.send(f"❌ Lỗi gửi webhook: {e}")

bot.run(BOT_TOKEN)