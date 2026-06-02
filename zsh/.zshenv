PATH=/usr/bin:/bin:/usr/sbin:/sbin
export ZSH_DISABLE_COMPFIX=true

# Homebrew — run from $HOME so brew's pwd-readability check survives
# iCloud-synced cwds (e.g., Obsidian vault) used by tmux session helpers.
eval "$(cd "$HOME" && /opt/homebrew/bin/brew shellenv)"
export PATH="$HOME/bin:$PATH"

# rbenv (shims in PATH for scripts; init in .zshrc)
export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"

# pyenv (root in PATH for scripts; init in .zshrc)
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

# Go
export GOARCH=arm64
export PATH="$PATH:/usr/local/go/bin"

# Tools
export PATH="/opt/homebrew/opt/mysql@8.4/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
