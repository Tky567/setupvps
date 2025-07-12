#!/data/data/com.termux/files/usr/bin/bash

pkg update -y && pkg upgrade -y

pkg install -y curl wget tur-repo

pkg update -y
pkg install -y python3.8

echo 'alias python=python3.8' >> ~/.bashrc
echo 'alias pip=pip3.8' >> ~/.bashrc
source ~/.bashrc