#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/.dotfiles"

# ── Dependencies ──────────────────────────────────────────────────────────────
if [[ "$(uname)" == "Darwin" ]]; then
  command -v brew &>/dev/null || \
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  brew install stow git vim tmux the_silver_searcher fzf pure go git-delta nvm
else
  sudo apt-get update
  sudo apt-get install -y stow git vim tmux silversearcher-ag fzf zsh git-delta
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
# Remove old symlinks and real files before stowing
for target in ~/.zshrc ~/.zshenv ~/.gitconfig ~/.gitignore_global \
              ~/.tmux.conf ~/.vimrc ~/.git_template \
              ~/.claude/CLAUDE.md ~/.claude/settings.json \
              ~/.config/alacritty/alacritty.toml \
              ~/.pi/agent/AGENTS.md; do
  [[ -L "$target" ]] && rm "$target"
  [[ -f "$target" && ! -L "$target" ]] && rm "$target"
done
[[ -L ~/bin ]] && rm ~/bin
[[ -d ~/bin && ! -L ~/bin ]] && rm -rf ~/bin

cd "$DOTFILES"
stow --target="$HOME" zsh git vim tmux bin claude alacritty

# ── Zsh plugins ───────────────────────────────────────────────────────────────
[[ -d ~/.zsh/zsh-autosuggestions ]] || \
  git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions

# ── fzf shell integration (generates ~/.fzf.zsh) ─────────────────────────────
# fzf --zsh works on both macOS and Linux (fzf 0.48+)
[[ -f ~/.fzf.zsh ]] || fzf --zsh > ~/.fzf.zsh

# ── gopls ─────────────────────────────────────────────────────────────────────
go install golang.org/x/tools/gopls@latest

# ── tmux-resurrect ────────────────────────────────────────────────────────────
[[ -d ~/.tmux/plugins/tmux-resurrect ]] || \
  git clone https://github.com/tmux-plugins/tmux-resurrect ~/.tmux/plugins/tmux-resurrect

# ── vim-plug + plugins ────────────────────────────────────────────────────────
# Install vim-plug if not present (required before :PlugInstall)
[[ -f ~/.vim/autoload/plug.vim ]] || \
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

vim +PlugInstall +qall

# ── nvm + Node 22 (default) ───────────────────────────────────────────────────
# nvm itself is installed above (brew on macOS, install script on Linux).
export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"
if [[ "$(uname)" == "Darwin" ]]; then
  # Homebrew's nvm: load from its formula prefix.
  [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]] && source "/opt/homebrew/opt/nvm/nvm.sh"
else
  # Linux: nvm has no apt package, install via official script.
  [[ -s "$NVM_DIR/nvm.sh" ]] || \
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  source "$NVM_DIR/nvm.sh"
fi
nvm install 22
nvm alias default 22

# ── Global agent rules (pi reads AGENTS.md, Claude Code reads CLAUDE.md) ──────
# Single source of truth lives in claude/.claude/CLAUDE.md; pi sees the same
# file via this symlink. Not a stow package: one file, simpler as a direct ln.
mkdir -p ~/.pi/agent
ln -sf "$DOTFILES/claude/.claude/CLAUDE.md" ~/.pi/agent/AGENTS.md

# ── Agent skills (vault-hosted so they're reviewable/editable in Obsidian) ────
# Real files live in the vault (iCloud syncs them to mobile); agents point at
# them. Symlink may dangle until iCloud syncs on a fresh machine — that's fine.
VAULT="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents"
ln -sfn "$VAULT/skills" ~/.claude/skills
# pi discovers skills via a settings.json array (idempotent merge — the file
# holds mutable pi state, so it can't be stow-managed or overwritten)
python3 - <<'PYEOF'
import json, os
p = os.path.expanduser("~/.pi/agent/settings.json")
s = json.load(open(p)) if os.path.exists(p) else {}
path = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/skills"
skills = s.get("skills", [])
if path not in skills:
    skills.append(path)
    s["skills"] = skills
    json.dump(s, open(p, "w"), indent=2)
PYEOF
