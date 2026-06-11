## Command history configuration
#
# Dedupe policy (industry best practice, 2025):
#   - keep the full history on disk (disk is cheap, lost commands are expensive)
#   - collapse only CONSECUTIVE duplicates as you type
#   - hide duplicates in incremental search results
#   - when SAVEHIST overflows, drop dupes before uniques
#
# Do NOT use `hist_ignore_all_dups`: it deletes *all* earlier copies of a
# command every time you re-run it, which silently shrinks your history
# (the classic "Ctrl+R can't find commands I know I ran" gotcha).

if [ -z "$HISTFILE" ]; then
  HISTFILE=$HOME/.zsh_history
fi

HISTSIZE=100000
SAVEHIST=100000

# `history` builtin alias — honors HIST_STAMPS if exported by something upstream
case $HIST_STAMPS in
  "mm/dd/yyyy") alias history='fc -fl 1' ;;
  "dd.mm.yyyy") alias history='fc -El 1' ;;
  "yyyy-mm-dd") alias history='fc -il 1' ;;
  *) alias history='fc -l 1' ;;
esac

# Writing & sharing
setopt append_history          # append on exit instead of overwriting
setopt inc_append_history      # write each command as it runs (implied by share_history)
setopt share_history           # merge history across concurrent sessions
setopt extended_history        # save timestamp + duration per entry

# Dedupe — preserve full history on disk, dedupe only in search and on overflow
setopt hist_ignore_dups        # skip if identical to the immediately previous command
setopt hist_find_no_dups       # don't surface duplicates in incremental search
setopt hist_expire_dups_first  # when SAVEHIST overflows, drop dupes before uniques

# Hygiene
setopt hist_ignore_space       # leading-space commands stay out of history (handy for secrets)
setopt hist_reduce_blanks      # strip extra whitespace before saving
setopt hist_verify             # don't auto-run history expansion (!!, !$) — require Enter
