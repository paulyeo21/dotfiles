export PS1='%n@%1~$ ' # custom prompt: paulyeo@exodia$
export EDITOR="vim"
export REACT_EDITOR='vim'

# Command history configuration
if [ -z "$HISTFILE" ]; then
  HISTFILE=$HOME/.zsh_history
fi

HISTSIZE=10000
SAVEHIST=10000

# Show history
case $HIST_STAMPS in
  "mm/dd/yyyy") alias history='fc -fl 1' ;;
  "dd.mm.yyyy") alias history='fc -El 1' ;;
  "yyyy-mm-dd") alias history='fc -il 1' ;;
  *) alias history='fc -l 1' ;;
esac

setopt appendhistory
setopt extendedhistory
setopt hist_expire_dups_first
setopt hist_ignore_dups        # ignore duplication command history list
setopt hist_ignore_space
setopt hist_verify
setopt incappendhistory
setopt sharehistory            # share command history data

# Keybindings
bindkey -v
bindkey "^a" beginning-of-line
bindkey "^e" end-of-line
bindkey "^R" history-incremental-search-backward

# Aliases
alias ls="ls -FG"
alias ll="ls -lh"
alias ip="ifconfig | grep inet"
alias rm="rm -i"
alias cp="cp -r"
alias pip="pip3"
alias python="python3"
alias vim="nvim"

alias b=brazil
alias bb=brazil-build
alias bba='brazil-build apollo-pkg'
alias bre='brazil-runtime-exec'
alias brc='brazil-recursive-cmd'
alias bws='brazil ws'
alias bwsuse='bws use --gitMode -p'
alias bwscreate='bws create -n'
alias brc=brazil-recursive-cmd
alias bbr='brc brazil-build'
alias bball='brc --allPackages'
alias bbb='brc --allPackages brazil-build'
alias bbra='bbr apollo-pkg'

alias icreds='eval $(isengardcli credentials paulyeo+testing@amazon.com --role Admin)'
