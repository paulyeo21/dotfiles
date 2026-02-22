#!/usr/bin/env bash
# validate.sh — smoke-test that dotfiles are correctly installed and configured.
# Run after any change or re-stow. Exits non-zero if any test fails.

DOTFILES="${HOME}/.dotfiles"
PASS=0
FAIL=0

GREEN='\033[0;32m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

pass() { echo -e "  ${GREEN}✓${RESET} $1"; PASS=$((PASS+1)); }
fail() { echo -e "  ${RED}✗${RESET} $1"; FAIL=$((FAIL+1)); }
section() { echo -e "\n${BOLD}$1${RESET}"; }

# ── Symlinks ──────────────────────────────────────────────────────────────────
# Checks that target is a symlink whose destination contains the expected path.
check_symlink() {
  local target="$1" expected="$2"
  if [[ -L "$target" ]] && [[ "$(readlink "$target")" == *"$expected"* ]]; then
    pass "$target"
  elif [[ -L "$target" ]]; then
    fail "$target → $(readlink "$target") (expected path containing '$expected')"
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

# ── File existence ────────────────────────────────────────────────────────────
check_file() {
  local f="$1"
  [[ -e "$f" ]] && pass "$f" || fail "missing: $f"
}

section "Stow package files"
check_file "$DOTFILES/zsh/.zshrc"
check_file "$DOTFILES/zsh/.zshenv"
check_file "$DOTFILES/git/.gitconfig"
check_file "$DOTFILES/git/.gitignore_global"
check_file "$DOTFILES/vim/.vimrc"
check_file "$DOTFILES/tmux/.tmux.conf"
check_file "$DOTFILES/bin/bin/git-pr"
check_file "$DOTFILES/bin/bin/git-publish"
check_file "$DOTFILES/bin/bin/tat"

section "Zsh config files"
for name in activate alias completion fancy_ctrl_z general git history keybindings tmux; do
  check_file "$DOTFILES/zsh/.zsh/config/${name}.zsh"
done

# ── File permissions ──────────────────────────────────────────────────────────
section "Permissions"
for script in git-pr git-publish tat; do
  f="${HOME}/bin/${script}"
  [[ -x "$f" ]] && pass "executable: $f" || fail "not executable: $f"
done

# ── Zsh shell ─────────────────────────────────────────────────────────────────
section "Zsh shell"

# Capture stdout and stderr separately from one interactive shell invocation
ZSH_OUT=$(zsh -i -c 'type g; type k; type kgp; type kgd' 2>/dev/null)
ZSH_ERR=$(zsh -i -c 'type g; type k; type kgp; type kgd' 2>&1 1>/dev/null)

echo "$ZSH_OUT" | grep -q "g is a shell function" \
  && pass "g is a shell function" || fail "g is not defined as a shell function"

for alias_name in k kgp kgd; do
  echo "$ZSH_OUT" | grep -q "${alias_name} is an alias" \
    && pass "${alias_name} is an alias" || fail "${alias_name} is not defined as an alias"
done

if echo "$ZSH_ERR" | grep -qE "compdef|compinit.*abort|insecure"; then
  fail "zsh startup errors:\n$(echo "$ZSH_ERR" | grep -E 'compdef|compinit|insecure')"
else
  pass "no compinit/compdef errors on startup"
fi

# ── Git config ────────────────────────────────────────────────────────────────
section "Git config"
check_git() {
  local key="$1" expected="$2"
  local val
  val=$(git config --global "$key" 2>/dev/null || true)
  if [[ "$val" == *"$expected"* ]]; then
    pass "git $key"
  else
    fail "git $key: expected value containing '$expected', got '$val'"
  fi
}

check_git "core.editor"       "vim"
check_git "core.excludesfile" ".gitignore_global"
check_git "alias.vlog"        "log --graph"
check_git "alias.pru"         "fetch --prune"

# ── Summary ───────────────────────────────────────────────────────────────────
TOTAL=$((PASS+FAIL))
echo
echo "────────────────────────────────────────"
echo -e "  ${GREEN}${PASS} passed${RESET}  ${RED}${FAIL} failed${RESET}  (${TOTAL} total)"

[[ $FAIL -eq 0 ]]
