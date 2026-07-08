# ── Shell ─────────────────────────────────────────────────────────────────────
alias ls="ls -FG"
alias ll="ls -lh"
alias cp="cp -r"
alias ip="ifconfig | grep inet"
mkcd() { mkdir -p "$1" && cd "$1"; }

# ── Dotfiles ──────────────────────────────────────────────────────────────────
# Fuzzy-search the CLAUDE.md reference tables (functions, aliases, keybindings)
dot() {
  grep -h '^|' "$HOME/.dotfiles/CLAUDE.md" | grep -v -- '---' \
    | fzf --prompt='dotfiles: ' --reverse --height=~20
}

# ── Languages ─────────────────────────────────────────────────────────────────
alias pip="pip3"
alias python="python3"
alias ctags="$(which ctags)"

# ── Kubernetes ────────────────────────────────────────────────────────────────
alias k="kubectl"
alias kgp="kubectl get pods"
alias kgd="kubectl get deploy"

# ── Tilt ──────────────────────────────────────────────────────────────────────
alias tl="tilt up --context docker-desktop -- --fe_env dev_mtsaas"

# ── Wandb Scripts ─────────────────────────────────────────────────────────────
wb() {
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<'EOF'
wb — run a wandb script against an environment

Usage: wb [sdk] <env> script.py [args]

  sdk    prepend local SDK checkout to PYTHONPATH
  env    prod | qa | qa-aws | qa-azure | qa-google | xxl-perf | dev

Examples:
  wb prod backfill.py
  wb sdk dev repro.py --flag
EOF
    return 0
  fi
  local PYTHON_PATH=/Users/paulyeo/Develop/wb/wandb
  local sdk_path=""
  if [[ "$1" == "sdk" ]]; then
    sdk_path=$PYTHON_PATH
    shift
  fi
  local env="$1"; shift
  case "$env" in
    prod)      WANDB_BASE_URL=https://api.wandb.ai      PYTHONPATH=$sdk_path python "$@" ;;
    qa)        WANDB_BASE_URL=https://api.qa.wandb.ai    PYTHONPATH=$sdk_path python "$@" ;;
    qa-aws)    WANDB_BASE_URL=https://qa-aws.wandb.io    PYTHONPATH=$sdk_path python "$@" ;;
    qa-azure)  WANDB_BASE_URL=https://qa-azure.wandb.io  PYTHONPATH=$sdk_path python "$@" ;;
    qa-google) WANDB_BASE_URL=https://qa-google.wandb.io PYTHONPATH=$sdk_path python "$@" ;;
    xxl-perf)  WANDB_BASE_URL=https://xxl-perf-testing.wandb.io PYTHONPATH=$sdk_path python "$@" ;;
    dev)       WANDB_BASE_URL=https://api.wandb.test     PYTHONPATH=$sdk_path python "$@" ;;
    *)         wb --help >&2; return 1 ;;
  esac
}

# ── Wandb MySQL ───────────────────────────────────────────────────────────────
wbdb() {
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<'EOF'
wbdb — connect to a wandb MySQL database

Usage: wbdb <prod|qa|dev> [flat|usage]

  flat     flat-tables variant
  usage    usage db (dev only)

prod/qa tunnel via 127.0.0.1:3307 and prompt for a password; dev uses
local docker with password "wandb".

Examples:
  wbdb prod
  wbdb dev flat
EOF
    return 0
  fi
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
      wbdb --help >&2; return 1 ;;
  esac
}

# ── Claude Code ──────────────────────────────────────────────────────────────
alias cw="claude --worktree"

# ── Notes (Obsidian vault via iCloud) ─────────────────────────────────────────
VAULT="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents"
alias note='vim "$VAULT/daily/$(date +%Y-%m-%d).md"'
alias notes='cd "$VAULT" && vim +Files'

# Copy markdown into the vault's topics/ for mobile viewing (iCloud syncs it)
topic() {
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<'EOF'
topic — copy markdown into the Obsidian vault's topics/ for mobile

Usage: topic <file.md> [more.md ...]

Files are copied to "$VAULT/topics"; iCloud syncs them to Obsidian mobile.
EOF
    return 0
  fi
  [[ $# -eq 0 ]] && { topic --help >&2; return 1; }
  local dest="$VAULT/topics"
  mkdir -p "$dest"
  cp "$@" "$dest/" && echo "→ $dest"
}

# ── Networking ────────────────────────────────────────────────────────────────
alias fix-gov='(
     echo "
     rdr pass inet proto tcp from any to any port 80 -> 127.0.0.1 port 9080
     rdr pass inet proto tcp from any to any port 443 -> 127.0.0.1 port 9443
     " | sudo pfctl -ef -
   ) && (
       printf "rdr pass inet proto tcp from any to any port = 80 -> 127.0.0.1 port 9080\nrdr pass inet proto tcp from any to any port = 443 -> 127.0.0.1 port 9443\n" | sudo pfctl -ef -
     )'
