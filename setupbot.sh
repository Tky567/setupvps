#!/bin/bash
termux-setup-storage && yes
pkg update && yes
pkg upgrade && yes
pkg install python git
pip install -U pip
pip install -U discord.py
cd /sdcard/Download/ && python bot.py
