#!/bin/bash
termux-setup-storage -y
pkg update -y
pkg upgrade -y
pkg install wget -y
pkg install python git
pip install -U pip
pip install -U discord.py
pip install python-dotenv
wget -o /storage/emulated/0/Download/discord-bot.zip https://github.com/Tky567/setupvps/raw/refs/heads/main/discord-bot.zip
unzip discord-bot.zip
cd /sdcard/Download/discord-bot && python free.py
