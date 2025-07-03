#!/data/data/com.termux/files/usr/bin/bash

yes | sudo apt update && yes | sudo apt upgrade

sudo apt-get install -y wget unzip python git

sudo apt-get install python-pip -y
pip install -U discord.py python-dotenv requests

cd /storage/emulated/0/Download/
wget -c https://github.com/Tky567/setupvps/raw/refs/heads/tky/discord-bot.zip -O discord-bot.zip

unzip -o discord-bot.zip

cd /sdcard/download/discord-bot/
wget -c https://gist.githubusercontent.com/Tky567/72e45ee3dfb3069e27ff4301551515aa/raw/ae94db72e20e0b2cda5b2b957bd32aba1ce33e73/config.env

cd /sdcard/download/discord-bot/
python free.py
