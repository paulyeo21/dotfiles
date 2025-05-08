# List of aliases

alias ls="ls -FG"
alias ll="ls -lh"
alias ip="ifconfig | grep inet"
alias rm="rm -i"
alias cp="cp -r"
alias ctags="/usr/local/bin/ctags"
alias pip="pip3"
alias python="python3"

alias fix-gov='(
     echo "
     rdr pass inet proto tcp from any to any port 80 -> 127.0.0.1 port 9080
     rdr pass inet proto tcp from any to any port 443 -> 127.0.0.1 port 9443
     " | sudo pfctl -ef -
   ) && (
       printf "rdr pass inet proto tcp from any to any port = 80 -> 127.0.0.1 port 9080\nrdr pass inet proto tcp from any to any port = 443 -> 127.0.0.1 port 9443\n" | sudo pfctl -ef -
     )'
