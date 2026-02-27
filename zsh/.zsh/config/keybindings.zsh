bindkey -v

# Restore useful emacs bindings that vim mode removes
bindkey "^a" beginning-of-line
bindkey "^e" end-of-line
bindkey "^R" history-incremental-search-backward
bindkey "^p" up-line-or-history
bindkey "^n" down-line-or-history
bindkey "^w" backward-kill-word
bindkey "^u" kill-whole-line
