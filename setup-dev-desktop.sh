# setup dotfiles
if [ ! -d "$HOME/.dotfiles" ]; then
  git clone git@github.com:paulyeo21/dotfiles.git "$HOME/.dotfiles"
fi
ln -s "$HOME/.dotfiles/vim/vimrc" "$HOME/.vimrc"
ln -s "$HOME/.dotfiles/zsh/zshrc" "$HOME/.zshrc"
ln -s "$HOME/.dotfiles/git/gitconfig" "$HOME/.gitconfig"
ln -s "$HOME/.dotfiles/tmux/tmux.conf" "$HOME/.tmux.conf"
ln -s "$HOME/.dotfiles/git/gitignore_global" "$HOME/.gitignore_global"
ln -s "$HOME/.dotfiles/bin" "$HOME"

# setup zsh
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

ln -s "$HOME/.dotfiles/zsh/zshrc" "$HOME/.zshrc"
ln -s "$HOME/.dotfiles/zsh/zshenv" "$HOME/.zshenv"

# setup vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

vim +PlugInstall +qall

# setup tmux
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

ln -s "$HOME/.dotfiles/tmux/tmux.reset.conf" "$HOME/.tmux.reset.conf"
ln -s "$HOME/.dotfiles/git/git_template" "$HOME/.git_template"

# install tmux version 2.6 from source
sudo yum install -y ncurses-devel.aarch64 libevent-devel.aarch64
git clone git@github.com:tmux/tmux.git
cd tmux
./configure && make
sudo make install
cd .. && rm -rf tmux # cleanup

# install protobuf-compiler from source
curl -LO "https://github.com/protocolbuffers/protobuf/releases/download/v3.15.8/protoc-3.15.8-linux-aarch_64.zip"
unzip protoc-3.15.8-linux-aarch_64.zip -d $HOME/.local
sudo cp $HOME/.local/bin/protoc /usr/local/bin
sudo chmod +x /usr/local/bin/protoc
rm -rf $HOME/.local && rm protoc-3.15.8-linux-aarch_64.zip # cleanup

# install ag from source
git clone git@github.com:ggreer/the_silver_searcher.git
cd the_silver_searcher
./build.sh
sudo make install
cd .. && rm -rf the_silver_searcher # cleanup

echo "FINISHED"
