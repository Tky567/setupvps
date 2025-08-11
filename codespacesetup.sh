#!/usr/bin/env bash
set -e

# Cài pyenv
curl https://pyenv.run | bash

# Cấu hình shell cho pyenv
{
  echo ''
  echo '# pyenv config'
  echo 'export PYENV_ROOT="$HOME/.pyenv"'
  echo 'export PATH="$PYENV_ROOT/bin:$PATH"'
  echo 'eval "$(pyenv init --path)"'
  echo 'eval "$(pyenv init -)"'
} >> ~/.bashrc

# Load lại cấu hình ngay
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# Cài Python 3.9.18
pyenv install 3.9.18
pyenv global 3.9.18

# Cài pip cho Python 3.9.18
curl -sS https://bootstrap.pypa.io/get-pip.py | python

# Kiểm tra
python --version
pip --version