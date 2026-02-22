#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/.dotfiles"

if [[ "$(uname)" == "Darwin" ]]; then
  command -v brew &>/dev/null || \
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  brew install stow git vim tmux the_silver_searcher
else
  sudo apt-get update
  sudo apt-get install -y stow git vim tmux silversearcher-ag
fi

# Remove old non-stow symlinks before stowing
for target in ~/.zshrc ~/.zshenv ~/.gitconfig ~/.gitignore_global \
              ~/.tmux.conf ~/.vimrc ~/.git_template; do
  [[ -L "$target" ]] && rm "$target"
done

cd "$DOTFILES"
stow --target="$HOME" zsh git vim tmux bin

# zsh-autosuggestions
[[ -d ~/.zsh/zsh-autosuggestions ]] || \
  git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions

# vim plugins
vim +PlugInstall +qall
