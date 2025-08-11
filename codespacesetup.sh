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

# Load lại cấu hình
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# Cài Python 3.8.18
pyenv install 3.8.18
pyenv global 3.8.18

# Kiểm tra
python --version