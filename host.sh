#!/data/data/com.termux/files/usr/bin/bash

pip install -U discord.py python-dotenv requests

wget -c https://raw.githubusercontent.com/Tky567/setupvps/refs/heads/tky/free.py

wget -c https://gist.githubusercontent.com/Tky567/72e45ee3dfb3069e27ff4301551515aa/raw/ae94db72e20e0b2cda5b2b957bd32aba1ce33e73/config.env

cd discord-bot
python free.py
