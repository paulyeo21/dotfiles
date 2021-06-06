install_dependencies() {
  sudo apt-get install -y vim
  sudo apt-get install -y git
  sudo apt-get install -y tmux
  sudo apt-get install -y xclip
  sudo apt-get install -y zsh
  sudo apt-get install -y silversearcher-ag
  sudo apt-get install -y exuberant-ctags
}

setup_dotfiles() {
  if [ ! -d "$HOME/.dotfiles" ]; then
    git clone https://github.com/paulyeo21/dotfiles.git "$HOME/.dotfiles"
  fi
  ln -s "$HOME/.dotfiles/vim/vimrc" "$HOME/.vimrc"
  ln -s "$HOME/.dotfiles/zsh/zshrc" "$HOME/.zshrc"
  ln -s "$HOME/.dotfiles/git/gitconfig" "$HOME/.gitconfig"
  ln -s "$HOME/.dotfiles/tmux/tmux.conf" "$HOME/.tmux.conf"
  ln -s "$HOME/.dotfiles/git/gitignore_global" "$HOME/.gitignore_global"
  ln -s "$HOME/.dotfiles/ctags" "$HOME/.ctags"
}

setup_zsh() {
  if [ ! -d "$HOME/.zsh/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
  fi

  local shell_path;
  shell_path="$(command -v zsh)"

  if [ "$shell_path" != "/usr/bin/zsh" ]; then
    if ! grep "$shell_path" /etc/shells > /dev/null 2>&1 ; then
      sudo sh -c "echo $shell_path >> /etc/shells"
    fi
    sudo chsh -s "$shell_path" "$USER"
  fi
}

setup_vim() {
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  vim +PlugInstall +qall
}

setup_tmux() {
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi
  ln -s "$HOME/.dotfiles/tmux/tmux.reset.conf" "$HOME/.tmux.reset.conf"
}

install_dependencies
setup_dotfiles
setup_zsh
setup_vim
setup_tmux

ln -s "$HOME/.dotfiles/git/git_template" "$HOME/.git_template"

echo "FINISHED"
