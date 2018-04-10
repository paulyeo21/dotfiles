PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin
export MYSQL_PATH=/usr/local/Cellar/mysql/5.7.17
export PATH="/Users/paulyeo/.rbenv/shims:/Users/paulyeo/.rbenv/bin:/usr/local/bin:/bin:/usr/bin:/usr/sbin:/sbin:/Users/paulyeo/bin:$MYSQL_PATH/bin:/Users/paulyeo/miniconda3/bin"

alias ls="ls -FG"
alias ll="ls -l"
alias be="bundle exec"

# if [ -f ~/.bashrc ]; then
#    source ~/.bashrc
# fi

[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
# source ~/git-completion.bash

for script in $HOME/.dotfiles/bash/config/*; do
	source $script
done

# ensure_tmux_is_running

# Preserve bash history in multiple bash shells
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
