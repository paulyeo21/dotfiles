fpath+=("$(brew --prefix)/share/zsh/site-functions")
autoload -U compinit
compinit -u

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
