#!/bin/sh

install_homebrew() {
  if ! command -v brew >/dev/null; then
    echo "Installing homebrew..."
    /usr/bin/ruby -e \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
}

install_dependencies() {
  brew install git
  brew install zsh
  brew install tmux
}

setup_dotfiles() {
  if [ ! -d "~/.dotfiles" ]; then
    git clone https://github.com/paulyeo21/dotfiles.git ~/.dotfiles
  else
    git -C ~/.dotfiles pull
  fi
  ln -s ~/.dotfiles/vim/vimrc ~/.vimrc
  ln -s ~/.dotfiles/zsh/zshrc ~/.zshrc
  source ~/.zshrc
  ln -s ~/.dotfiles/git/gitconfig ~/.gitconfig
}

setup_vundle() {
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  vim +PluginInstall +qall
}

install_homebrew
install_dependencies
setup_dotfiles
setup_vundle
