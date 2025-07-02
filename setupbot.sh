#!/bin/bash
termux-setup-storage && yes
pkg update && yes
pkg upgrade && yes
pkg install unzip && yes
pkg install wget && yes
pkg install python git && yes
pip install -U pip
pip install -U discord.py
pip install python-dotenv
wget -c discord-bot.zip https://github.com/Tky567/setupvps/raw/refs/heads/main/discord-bot.zip
unzip discord-bot.zip
cd /sdcard/Download/discord-bot && python free.py
