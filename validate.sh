#!/usr/bin/env bash
# validate.sh — smoke test dotfiles installation.
# Run after setup.sh or re-stow. Exits non-zero if any test fails.

DOTFILES="${HOME}/.dotfiles"
PASS=0; FAIL=0

GREEN='\033[0;32m'; RED='\033[0;31m'; BOLD='\033[1m'; RESET='\033[0m'
pass()    { echo -e "  ${GREEN}✓${RESET} $1"; PASS=$((PASS+1)); }
fail()    { echo -e "  ${RED}✗${RESET} $1"; FAIL=$((FAIL+1)); }
section() { echo -e "\n${BOLD}$1${RESET}"; }

# ── Symlinks ──────────────────────────────────────────────────────────────────
check_symlink() {
  local target="$1" expected="$2"
  if [[ -L "$target" ]] && [[ "$(readlink "$target")" == *"$expected"* ]]; then
    pass "$target"
  elif [[ -L "$target" ]]; then
    fail "$target → $(readlink "$target") (expected '$expected')"
  else
    fail "$target is not a symlink"
  fi
}

section "Symlinks"
check_symlink ~/.zshrc            "dotfiles/zsh/.zshrc"
check_symlink ~/.zshenv           "dotfiles/zsh/.zshenv"
check_symlink ~/.gitconfig        "dotfiles/git/.gitconfig"
check_symlink ~/.gitignore_global "dotfiles/git/.gitignore_global"
check_symlink ~/.git_template     "dotfiles/git/.git_template"
check_symlink ~/.tmux.conf        "dotfiles/tmux/.tmux.conf"
check_symlink ~/.vimrc            "dotfiles/vim/.vimrc"
check_symlink ~/bin               "dotfiles/bin/bin"

# ── Binaries ──────────────────────────────────────────────────────────────────
check_cmd() {
  command -v "$1" &>/dev/null \
    && pass "$1 in PATH" \
    || fail "$1 not found — $2"
}

section "Binaries"
check_cmd vim   "brew install vim"
check_cmd tmux  "brew install tmux"
check_cmd git   "brew install git"
check_cmd ag    "brew install the_silver_searcher"
check_cmd fzf   "brew install fzf"
check_cmd go    "brew install go"
check_cmd gopls "go install golang.org/x/tools/gopls@latest"
check_cmd stow  "brew install stow"

# ── Zsh ───────────────────────────────────────────────────────────────────────
section "Zsh"

for name in activate alias completion fancy_ctrl_z general git history keybindings tmux; do
  [[ -f "$DOTFILES/zsh/.zsh/config/${name}.zsh" ]] \
    && pass "config/${name}.zsh" \
    || fail "config/${name}.zsh missing"
done

[[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]] \
  && pass "zsh-autosuggestions installed" \
  || fail "zsh-autosuggestions missing — run setup.sh"

[[ -f ~/.fzf.zsh ]] \
  && pass "fzf shell integration (~/.fzf.zsh)" \
  || fail "fzf shell integration missing — run: \$(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc"

ZSH_CMD='for f in ~/.zsh/config/*.zsh; do source "$f"; done; type g; type k; type tm'
ZSH_OUT=$(zsh -c "$ZSH_CMD" 2>/dev/null)
ZSH_ERR=$(zsh -c "$ZSH_CMD" 2>&1 1>/dev/null)

echo "$ZSH_OUT" | grep -q "g is a shell function"  && pass "g function"  || fail "g not defined"
echo "$ZSH_OUT" | grep -q "k is an alias"           && pass "k alias"    || fail "k not defined"
echo "$ZSH_OUT" | grep -q "tm is a shell function"  && pass "tm function" || fail "tm not defined"

echo "$ZSH_ERR" | grep -qE "compdef|compinit.*abort|insecure" \
  && fail "zsh startup errors: $(echo "$ZSH_ERR" | grep -E 'compdef|compinit|insecure')" \
  || pass "no zsh startup errors"

# ── Pure prompt ───────────────────────────────────────────────────────────────
section "Pure prompt"
[[ -f "$(brew --prefix)/share/zsh/site-functions/prompt_pure_setup" ]] \
  && pass "pure installed" \
  || fail "pure not installed — run: brew install pure"

# ── Vim ───────────────────────────────────────────────────────────────────────
section "Vim plugins"
for plugin in vim-go vim-tmux-navigator fzf.vim vim-surround vim-commentary jellybeans.vim; do
  [[ -d ~/.vim/bundle/${plugin} ]] \
    && pass "${plugin}" \
    || fail "${plugin} missing — run :PlugInstall in vim"
done

vim -es -u ~/.vimrc -c 'set clipboard?' -c 'qa!' 2>/dev/null | grep -q "clipboard=unnamed" \
  && pass "clipboard=unnamed" \
  || fail "clipboard not set to unnamed"

grep -q "go_def_mode.*gopls" ~/.vim/rcfiles/golang \
  && pass "vim-go using gopls" \
  || fail "vim-go not configured to use gopls"

# ── Tmux ──────────────────────────────────────────────────────────────────────
section "Tmux"
grep -q "tmux-256color" ~/.tmux.conf \
  && pass "default-terminal tmux-256color" \
  || fail "default-terminal should be tmux-256color"
grep -q "escape-time 0" ~/.tmux.conf \
  && pass "escape-time 0" \
  || fail "escape-time not 0 — vim-tmux-navigator will be sluggish"
grep -q "C-h.*is_vim\|is_vim.*C-h" ~/.tmux.conf \
  && pass "vim-tmux-navigator bindings" \
  || fail "vim-tmux-navigator tmux bindings missing"

# ── Git ───────────────────────────────────────────────────────────────────────
section "Git"
check_git() {
  local key="$1" expected="$2"
  local val; val=$(git config --global "$key" 2>/dev/null || true)
  [[ "$val" == *"$expected"* ]] \
    && pass "git $key" \
    || fail "git $key: expected '$expected', got '$val'"
}
check_git "core.editor"       "vim"
check_git "core.excludesfile" ".gitignore_global"
check_git "alias.vlog"        "log --graph"
check_git "alias.pru"         "fetch --prune"

# ── Docker ────────────────────────────────────────────────────────────────────
section "Docker"
DOCKER=$(zsh -c 'source ~/.zshrc 2>/dev/null; which docker' 2>/dev/null)
[[ -n "$DOCKER" ]] \
  && pass "docker in PATH ($DOCKER)" \
  || fail "docker not in PATH (is OrbStack running?)"
if [[ -n "$DOCKER" ]]; then
  zsh -c 'source ~/.zshrc 2>/dev/null; docker ps' &>/dev/null \
    && pass "docker daemon reachable" \
    || fail "docker daemon not reachable (is OrbStack running?)"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
TOTAL=$((PASS+FAIL))
echo
echo "────────────────────────────────────────"
echo -e "  ${GREEN}${PASS} passed${RESET}  ${RED}${FAIL} failed${RESET}  (${TOTAL} total)"
[[ $FAIL -eq 0 ]]
