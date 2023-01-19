echo "--- DOTFILES START ---"
if [ ! -d "$HOME/.dotfiles" ]; then
  git clone git@github.com:paulyeo21/dotfiles.git "$HOME/.dotfiles"
fi
ln -s "$HOME/.dotfiles/vim/vimrc" "$HOME/.vimrc"
ln -s "$HOME/.dotfiles/zsh/zshrc" "$HOME/.zshrc"
ln -s "$HOME/.dotfiles/git/gitconfig" "$HOME/.gitconfig"
ln -s "$HOME/.dotfiles/tmux/tmux.conf" "$HOME/.tmux.conf"
ln -s "$HOME/.dotfiles/git/gitignore_global" "$HOME/.gitignore_global"
ln -s "$HOME/.dotfiles/bin" "$HOME"

mkdir ~/develop
mkdir ~/downloads
echo "--- DOTFILES END ---"

echo "--- ZSH START ---"
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
echo "--- ZSH END ---"

ln -s "$HOME/.dotfiles/zsh/zshrc" "$HOME/.zshrc"
ln -s "$HOME/.dotfiles/zsh/zshenv" "$HOME/.zshenv"

echo "--- VIM START ---"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

vim +PlugInstall +qall
echo "--- VIM END ---"

echo "--- TMUX START ---"
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm # DONT FORGET prefix + I to take effect
fi

ln -s "$HOME/.dotfiles/git/git_template" "$HOME/.git_template"

# install tmux version 2.6 from source
sudo yum install -y ncurses-devel.aarch64 libevent-devel.aarch64
git clone git@github.com:tmux/tmux.git
cd tmux
sh autogen.sh
./configure && make
# cd .. && rm -rf tmux # cleanup
echo "--- TMUX END ---"

echo "--- PROTOBUF START ---"
curl -LO "https://github.com/protocolbuffers/protobuf/releases/download/v3.15.8/protoc-3.15.8-linux-aarch_64.zip"
unzip protoc-3.15.8-linux-aarch_64.zip -d $HOME/.local
sudo cp $HOME/.local/bin/protoc /usr/local/bin
sudo chmod +x /usr/local/bin/protoc
# rm -rf $HOME/.local && rm protoc-3.15.8-linux-aarch_64.zip # cleanup
echo "--- PROTOBUF END ---"

echo "--- AG START ---"
sudo yum install -y pcre-devel.aarch64 zlib-devel.aarch64 xz-devel.aarch64
git clone git@github.com:ggreer/the_silver_searcher.git
cd the_silver_searcher
./build.sh
sudo make install
# cd .. && rm -rf the_silver_searcher # cleanup
echo "--- AG END ---"

echo "--- RUST START ---"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | shcurl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup component add rust-src
rustup component add rustfmt
rustup component add rust-analyzer
ln ~/.rustup/toolchains/stable-aarch64-unknown-linux-gnu/bin/rust-analyzer ~/.cargo/bin/
echo "--- RUST END ---"

echo "--- ISENGARDCLI START ---"
cd ~/develop
git clone ssh://git.amazon.com/pkg/Isengard-cli
cd Isengard-cli
pip3 install .
sudo cp ~/.local/bin/isengardcli /usr/local/bin/
echo "--- ISENGARDCLI END ---"

echo "--- BRAZIL START ---"
toolbox install brazilcli
mkdir ~/develop/workspaces
echo "--- BRAZIL END ---"

echo "--- NEOVIM START ---"
sudo yum install -y cmake3.aarch64
sudo cp /usr/bin/cmake3 /usr/bin/cmake
git clone git@github.com:neovim/neovim.git
cd neovim
sudo make install

mkdir ~/.config/nvim/
echo "set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc" >> ~/.config/nvim/init.vim
echo "--- NEOVIM END ---"

# TODO
# autojump

echo "FINISHED"
