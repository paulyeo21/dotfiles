## Command history configuration
if [ -z "$HISTFILE" ]; then
  HISTFILE=$HOME/.zsh_history
fi

HISTSIZE=50000
SAVEHIST=50000

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
setopt hist_ignore_all_dups  # remove older duplicate entries throughout history
setopt hist_ignore_space
setopt hist_reduce_blanks    # strip extra whitespace before saving
setopt hist_verify
setopt incappendhistory
setopt sharehistory          # share command history across sessions
