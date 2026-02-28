#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/.dotfiles"

# ── Dependencies ──────────────────────────────────────────────────────────────
if [[ "$(uname)" == "Darwin" ]]; then
  command -v brew &>/dev/null || \
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  brew install stow git vim tmux the_silver_searcher fzf pure go
else
  sudo apt-get update
  sudo apt-get install -y stow git vim tmux silversearcher-ag fzf zsh
  # Install go from official binary (apt version is often outdated)
  if ! command -v go &>/dev/null; then
    GO_VERSION="1.23.0"
    GO_ARCH=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')
    curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz" \
      | sudo tar -C /usr/local -xzf -
    export PATH="$PATH:/usr/local/go/bin"
  fi
  # Install pure via npm (not in apt)
  if command -v npm &>/dev/null && [[ ! -d ~/.zsh/pure ]]; then
    git clone https://github.com/sindresorhus/pure.git ~/.zsh/pure
  fi
fi

# ── Stow ──────────────────────────────────────────────────────────────────────
# Remove old symlinks and real ~/bin directory before stowing
for target in ~/.zshrc ~/.zshenv ~/.gitconfig ~/.gitignore_global \
              ~/.tmux.conf ~/.vimrc ~/.git_template; do
  [[ -L "$target" ]] && rm "$target"
done
[[ -L ~/bin ]] && rm ~/bin
[[ -d ~/bin && ! -L ~/bin ]] && rm -rf ~/bin

cd "$DOTFILES"
stow --target="$HOME" zsh git vim tmux bin

# ── Zsh plugins ───────────────────────────────────────────────────────────────
[[ -d ~/.zsh/zsh-autosuggestions ]] || \
  git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions

# ── fzf shell integration (generates ~/.fzf.zsh) ─────────────────────────────
# fzf --zsh works on both macOS and Linux (fzf 0.48+)
[[ -f ~/.fzf.zsh ]] || fzf --zsh > ~/.fzf.zsh

# ── gopls ─────────────────────────────────────────────────────────────────────
go install golang.org/x/tools/gopls@latest

# ── vim-plug + plugins ────────────────────────────────────────────────────────
# Install vim-plug if not present (required before :PlugInstall)
[[ -f ~/.vim/autoload/plug.vim ]] || \
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

vim +PlugInstall +qall
