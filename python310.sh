#!/data/data/com.termux/files/usr/bin/bash

pkg update -y && pkg upgrade -y

pkg install -y curl wget tur-repo

pkg update -y
pkg install -y python3.10

mkdir -p $HOME/python310/bin
ln -sf $(which python3.10) $HOME/python310/bin/python
ln -sf $(which pip3.10) $HOME/python310/bin/pip

if ! grep -q 'export PATH=$HOME/python310/bin:$PATH' ~/.bashrc; then
    echo 'export PATH=$HOME/python310/bin:$PATH' >> ~/.bashrc
fi
source ~/.bashrc

python --version
pip --version
