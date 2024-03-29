#!/bin/sh

install_homebrew() {
  if ! command -v brew >/dev/null; then
    /usr/bin/ruby -e \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
}

install_dependencies() {
  brew install vim # macos vim has copy paste to clipboard issues
  brew install git
  #brew install zsh
  brew install tmux
  brew install the_silver_searcher
  brew install ctags
  alias ctags="`brew --prefix`/bin/ctags"
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

  if [ "$shell_path" != "/usr/local/bin/zsh" ]; then
    if ! grep "$shell_path" /etc/shells > /dev/null 2>&1 ; then
      sudo sh -c "echo $shell_path >> /etc/shells"
    fi
    sudo chsh -s "$shell_path" "$USER"
  fi

  ln -s "$HOME/.dotfiles/zsh/zshenv" "$HOME/.zshenv"
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

install_homebrew
install_dependencies
setup_dotfiles
setup_zsh
setup_vim
setup_tmux

ln -s "$HOME/.dotfiles/git/git_template" "$HOME/.git_template"
ln -s "$HOME/.dotfiles/bin" "$HOME/bin"

echo "Finished"

