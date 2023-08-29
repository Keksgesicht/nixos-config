#!/usr/bin/env bash

cd "$(realpath $(dirname $0))"

git clone 'https://github.com/zsh-users/zsh-autosuggestions'          zsh-autosuggestions
git clone 'https://github.com/zsh-users/zsh-history-substring-search' zsh-history-substring-search
git clone 'https://github.com/zsh-users/zsh-syntax-highlighting'      zsh-syntax-highlighting
git clone 'https://github.com/romkatv/powerlevel10k.git'              zsh-theme-powerlevel10k
