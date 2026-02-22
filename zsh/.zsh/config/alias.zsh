# List of aliases

alias ls="ls -FG"
alias ll="ls -lh"
alias ip="ifconfig | grep inet"
alias rm="rm -i"
alias cp="cp -r"
alias ctags="$(which ctags)"
alias pip="pip3"
alias python="python3"
alias k="kubectl"
alias kgp="kubectl get pods"
alias kgd="kubectl get deploy"
alias tl="/opt/homebrew/bin/tilt up --context docker-desktop"
alias tl_local="/opt/homebrew/bin/tilt up --context docker-desktop -- --fe_env local"
alias tl_integration="/opt/homebrew/bin/tilt up --context docker-desktop -- --fe_env integration"
alias wb_mysql_dev="mysql -u wandb --host 127.0.0.1 --port=3306 --database=wandb_dev --password=wandb"
alias wb_mysql_dev_flat="mysql -u wandb --host 127.0.0.1 --port=3312 --database=wandb_dev_flat --password=wandb"
alias wb_mysql_dev_usage="mysql -u wandb --host 127.0.0.1 --port=3318 --database=wandb_dev_usage --password=wandb"
alias wb_mysql_prod="mysql -u wandb --host 127.0.0.1 --port=3307 --database=wandb_production --password"
alias wb_mysql_prod_flat="mysql -u wandb --host 127.0.0.1 --port=3307 --database=wandb_flat_production --password"
alias wb_mysql_qa="mysql -u wandb --host 127.0.0.1 --port=3307 --database=wandb_qa --password"
alias wb_mysql_qa_flat="mysql -u wandb --host 127.0.0.1 --port=3307 --database=wandb_flat_qa --password"

alias fix-gov='(
     echo "
     rdr pass inet proto tcp from any to any port 80 -> 127.0.0.1 port 9080
     rdr pass inet proto tcp from any to any port 443 -> 127.0.0.1 port 9443
     " | sudo pfctl -ef -
   ) && (
       printf "rdr pass inet proto tcp from any to any port = 80 -> 127.0.0.1 port 9080\nrdr pass inet proto tcp from any to any port = 443 -> 127.0.0.1 port 9443\n" | sudo pfctl -ef -
     )'
