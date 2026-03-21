# ── Shell ─────────────────────────────────────────────────────────────────────
alias ls="ls -FG"
alias ll="ls -lh"
alias cp="cp -r"
alias ip="ifconfig | grep inet"

# ── Languages ─────────────────────────────────────────────────────────────────
alias pip="pip3"
alias python="python3"
alias ctags="$(which ctags)"

# ── Kubernetes ────────────────────────────────────────────────────────────────
alias k="kubectl"
alias kgp="kubectl get pods"
alias kgd="kubectl get deploy"

# ── Tilt ──────────────────────────────────────────────────────────────────────
alias tl="/opt/homebrew/bin/tilt up --context docker-desktop"
alias tl_local="/opt/homebrew/bin/tilt up --context docker-desktop -- --fe_env local"
alias tl_integration="/opt/homebrew/bin/tilt up --context docker-desktop -- --fe_env integration"

# ── Wandb Scripts ─────────────────────────────────────────────────────────────
wb() {
  local PYTHON_PATH=/Users/paulyeo/Develop/wb/wandb
  local sdk_path=""
  if [[ "$1" == "sdk" ]]; then
    sdk_path=$PYTHON_PATH
    shift
  fi
  local env="$1"; shift
  case "$env" in
    prod) WANDB_BASE_URL=https://api.wandb.ai    PYTHONPATH=$sdk_path python "$@" ;;
    qa)   WANDB_BASE_URL=https://api.qa.wandb.ai PYTHONPATH=$sdk_path python "$@" ;;
    dev)  WANDB_BASE_URL=https://api.wandb.test  PYTHONPATH=$sdk_path python "$@" ;;
    *)    echo "Usage: wb [sdk] <prod|qa|dev> script.py [args]"; return 1 ;;
  esac
}

# ── Wandb MySQL ───────────────────────────────────────────────────────────────
wbdb() {
  local env="$1" variant="${2:-}"
  case "$env" in
    prod)
      case "$variant" in
        flat)  mysql -u wandb --host 127.0.0.1 --port=3307 --database=wandb_flat_production --password ;;
        *)     mysql -u wandb --host 127.0.0.1 --port=3307 --database=wandb_production --password ;;
      esac ;;
    qa)
      case "$variant" in
        flat)  mysql -u wandb --host 127.0.0.1 --port=3307 --database=wandb_flat_qa --password ;;
        *)     mysql -u wandb --host 127.0.0.1 --port=3307 --database=wandb_qa --password ;;
      esac ;;
    dev)
      case "$variant" in
        flat)  mysql -u wandb --host 127.0.0.1 --port=3312 --database=wandb_dev_flat --password=wandb ;;
        usage) mysql -u wandb --host 127.0.0.1 --port=3318 --database=wandb_dev_usage --password=wandb ;;
        *)     mysql -u wandb --host 127.0.0.1 --port=3306 --database=wandb_dev --password=wandb ;;
      esac ;;
    *)
      echo "Usage: wbdb <prod|qa|dev> [flat|usage]"; return 1 ;;
  esac
}

# ── Claude Code ──────────────────────────────────────────────────────────────
alias cw="claude --worktree"

# ── Notes (Obsidian vault via iCloud) ─────────────────────────────────────────
VAULT="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents"
alias note='vim "$VAULT/daily/$(date +%Y-%m-%d).md"'
alias notes='cd "$VAULT" && vim +Files'

# ── Networking ────────────────────────────────────────────────────────────────
alias fix-gov='(
     echo "
     rdr pass inet proto tcp from any to any port 80 -> 127.0.0.1 port 9080
     rdr pass inet proto tcp from any to any port 443 -> 127.0.0.1 port 9443
     " | sudo pfctl -ef -
   ) && (
       printf "rdr pass inet proto tcp from any to any port = 80 -> 127.0.0.1 port 9080\nrdr pass inet proto tcp from any to any port = 443 -> 127.0.0.1 port 9443\n" | sudo pfctl -ef -
     )'
