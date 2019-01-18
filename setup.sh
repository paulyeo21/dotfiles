#!/bin/sh

install_homebrew() {
  if ! command -v brew >/dev/null; then
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
  ln -s ~/.dotfiles/git/gitconfig ~/.gitconfig
  ln -s ~/.dotfiles/tmux/tmux.conf ~/.tmux.conf
}

setup_zsh() {
  local shell_path;
  shell_path="$(command -v zsh)"

  if ! grep "$shell_path" /etc/shells > /dev/null 2>&1 ; then
    sudo sh -c "echo $shell_path >> /etc/shells"
  fi
  sudo chsh -s "$shell_path" "$USER"
}

setup_vundle() {
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  vim +PluginInstall +qall
}

setup_tpm() {
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  tmux source ~/.tmux.conf
}

install_homebrew
install_dependencies
setup_dotfiles
setup_zsh
setup_vundle
setup_tpm

echo "Finished"
