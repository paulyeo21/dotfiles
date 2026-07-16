export ZSH_DISABLE_COMPFIX=true

# Keep PATH ordered and duplicate-free while preserving paths inherited from
# macOS, terminal apps, corporate tooling, and parent processes.
typeset -U path PATH

# Homebrew — run from $HOME so brew's pwd-readability check survives
# iCloud-synced cwds (e.g., Obsidian vault) used by tmux session helpers.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(cd "$HOME" && /opt/homebrew/bin/brew shellenv)"
fi

# Executable paths needed by login shells, non-login shells (tmux), and scripts.
# Earlier entries win; inherited paths stay available at the end.
path=(
  "$HOME/bin"
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  "$HOME/.rbenv/shims"
  "$HOME/.rbenv/bin"
  "$HOME/go/bin"
  /opt/homebrew/opt/mysql@8.4/bin
  /opt/homebrew/opt/postgresql@17/bin
  /opt/homebrew/opt/openjdk/bin
  /opt/homebrew/bin
  /opt/homebrew/sbin
  /usr/local/bin
  /usr/local/sbin
  /usr/local/go/bin
  /usr/bin
  /bin
  /usr/sbin
  /sbin
  $path
)
export PATH

# Go
export GOARCH=arm64

[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

