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
check_symlink ~/Develop/AGENTS.md   "dotfiles/workspaces/Develop/AGENTS.md"
check_symlink ~/Develop/CLAUDE.md   "dotfiles/workspaces/Develop/CLAUDE.md"
check_symlink ~/Develop1/AGENTS.md  "dotfiles/workspaces/Develop1/AGENTS.md"
check_symlink ~/Develop1/CLAUDE.md  "dotfiles/workspaces/Develop1/CLAUDE.md"

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
check_cmd delta "brew install git-delta"

# ── Zsh ───────────────────────────────────────────────────────────────────────
section "Zsh"

for name in activate alias completion fancy_ctrl_z general git history keybindings tmux worktree; do
  [[ -f "$DOTFILES/zsh/.zsh/config/${name}.zsh" ]] \
    && pass "config/${name}.zsh" \
    || fail "config/${name}.zsh missing"
done

[[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]] \
  && pass "zsh-autosuggestions installed" \
  || fail "zsh-autosuggestions missing — run setup.sh"

# brew rejects iCloud-synced cwds; wrap brew calls so shells starting
# in the Obsidian vault (or any iCloud dir) don't crash on startup.
grep -q 'cd "$HOME" && /opt/homebrew/bin/brew shellenv' "$DOTFILES/zsh/.zshenv" \
  && pass "brew shellenv wrapped (.zshenv)" \
  || fail "brew shellenv not wrapped in 'cd \$HOME' — breaks shells started in iCloud dirs"
grep -q 'cd "$HOME" && brew --prefix' "$DOTFILES/zsh/.zsh/config/completion.zsh" \
  && pass "brew --prefix wrapped (completion.zsh)" \
  || fail "brew --prefix not wrapped in 'cd \$HOME' — breaks shells started in iCloud dirs"

# PATH contract: commands installed in standard local and Go user bins must
# work in non-login shells (tmux), without accumulating duplicate entries.
CLEAN_ZSH_PATH=$(env -i HOME="$HOME" PATH=/usr/bin:/bin:/usr/sbin:/sbin \
  /bin/zsh -c 'print -r -- "$PATH"' 2>/dev/null)
[[ ":$CLEAN_ZSH_PATH:" == *":/usr/local/bin:"* \
  && ":$CLEAN_ZSH_PATH:" == *":$HOME/go/bin:"* ]] \
  && pass "non-login PATH includes /usr/local/bin and ~/go/bin" \
  || fail "non-login PATH missing /usr/local/bin or ~/go/bin"
[[ -z "$(printf '%s' "$CLEAN_ZSH_PATH" | tr ':' '\n' | sort | uniq -d)" ]] \
  && pass "PATH entries are unique" \
  || fail "PATH contains duplicate entries"

[[ -f ~/.fzf.zsh ]] \
  && pass "fzf shell integration (~/.fzf.zsh)" \
  || fail "fzf shell integration missing — run: \$(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc"

ZSH_CMD='for f in ~/.zsh/config/*.zsh; do source "$f"; done; type g; type k; type tm; type topic; type dot; type wt'
ZSH_OUT=$(zsh -c "$ZSH_CMD" 2>/dev/null)
ZSH_ERR=$(zsh -c "$ZSH_CMD" 2>&1 1>/dev/null)

echo "$ZSH_OUT" | grep -q "g is a shell function"  && pass "g function"  || fail "g not defined"
echo "$ZSH_OUT" | grep -q "k is an alias"           && pass "k alias"    || fail "k not defined"
echo "$ZSH_OUT" | grep -q "tm is a shell function"  && pass "tm function" || fail "tm not defined"
echo "$ZSH_OUT" | grep -q "topic is a shell function" && pass "topic function" || fail "topic not defined"
echo "$ZSH_OUT" | grep -q "dot is a shell function"   && pass "dot function"   || fail "dot not defined"
echo "$ZSH_OUT" | grep -q "wt is a shell function"    && pass "wt function"    || fail "wt not defined"

# Help convention: functions with args respond to --help (wb as representative)
zsh -c 'for f in ~/.zsh/config/*.zsh; do source "$f"; done; wb --help' 2>/dev/null | grep -q "Usage: wb" \
  && pass "wb --help prints usage" \
  || fail "wb --help broken — help convention regressed"

echo "$ZSH_ERR" | grep -qE "compdef|compinit.*abort|insecure" \
  && fail "zsh startup errors: $(echo "$ZSH_ERR" | grep -E 'compdef|compinit|insecure')" \
  || pass "no zsh startup errors"

# History dedupe policy: must keep full history (not hist_ignore_all_dups, which silently shrinks it)
HIST_FILE="$DOTFILES/zsh/.zsh/config/history.zsh"
grep -qE '^[[:space:]]*setopt[[:space:]]+hist_ignore_all_dups\b' "$HIST_FILE" \
  && fail "hist_ignore_all_dups still set — deletes earlier dupes on every re-run, shrinks history" \
  || pass "hist_ignore_all_dups not set"
grep -q '^setopt hist_ignore_dups' "$HIST_FILE" \
  && pass "hist_ignore_dups (consecutive dupes only)" \
  || fail "hist_ignore_dups missing in history.zsh"
grep -q '^setopt hist_find_no_dups' "$HIST_FILE" \
  && pass "hist_find_no_dups (dedupe in search results only)" \
  || fail "hist_find_no_dups missing in history.zsh"
grep -qE '^(HISTSIZE|SAVEHIST)=100000' "$HIST_FILE" \
  && pass "HISTSIZE/SAVEHIST=100000" \
  || fail "HISTSIZE/SAVEHIST should be 100000 in history.zsh"


# ── nvm / Node ────────────────────────────────────────────────────────────────
section "nvm / Node"
# Strip ANSI color codes — nvm output is colorized by default.
NVM_OUT=$(zsh -ic 'nvm current; nvm alias default' 2>/dev/null | sed $'s/\x1b\\[[0-9;]*m//g')
echo "$NVM_OUT" | grep -q '^v22\.' \
  && pass "node default is v22 ($(echo "$NVM_OUT" | head -1))" \
  || fail "node default not v22 — run: nvm install 22 && nvm alias default 22"
echo "$NVM_OUT" | grep -qE 'default -> 22' \
  && pass "nvm alias default -> 22" \
  || fail "nvm alias default not pinned to 22 — run: nvm alias default 22"

# ── Pure prompt ───────────────────────────────────────────────────────────────
section "Pure prompt"
if [[ "$(uname)" == "Darwin" ]]; then
  [[ -f "$(brew --prefix)/share/zsh/site-functions/prompt_pure_setup" ]] \
    && pass "pure installed" \
    || fail "pure not installed — run: brew install pure"
else
  [[ -f ~/.zsh/pure/pure.zsh ]] \
    && pass "pure installed" \
    || fail "pure not installed — run: git clone https://github.com/sindresorhus/pure.git ~/.zsh/pure"
fi

# ── Vim ───────────────────────────────────────────────────────────────────────
section "Vim plugins"
[[ -f ~/.vim/autoload/plug.vim ]] \
  && pass "vim-plug installed" \
  || fail "vim-plug not installed — run setup.sh"
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
[[ -d ~/.tmux/plugins/tmux-resurrect ]] \
  && pass "tmux-resurrect installed" \
  || fail "tmux-resurrect missing — run setup.sh"

# ── Agent rules (Claude Code + pi share one file) ─────────────────────────────
section "Agent rules"
[[ -L ~/.claude/CLAUDE.md ]] \
  && pass "~/.claude/CLAUDE.md symlinked" \
  || fail "~/.claude/CLAUDE.md not symlinked — run setup.sh"
[[ -L ~/.claude/settings.json ]] \
  && pass "~/.claude/settings.json symlinked" \
  || fail "~/.claude/settings.json not symlinked — run setup.sh"

# Pi reads ~/.pi/agent/AGENTS.md — must resolve to the same dotfiles file
# so Claude Code and pi see identical global instructions.
AGENT_RULES="$DOTFILES/claude/.claude/CLAUDE.md"
if [[ -L ~/.pi/agent/AGENTS.md ]] && [[ "$(readlink -f ~/.pi/agent/AGENTS.md 2>/dev/null)" == "$(readlink -f "$AGENT_RULES" 2>/dev/null)" ]]; then
  pass "~/.pi/agent/AGENTS.md -> claude/.claude/CLAUDE.md"
else
  fail "~/.pi/agent/AGENTS.md missing or pointing elsewhere — run setup.sh"
fi
grep -q '^## Code editing principles' "$AGENT_RULES" \
  && pass "Code editing principles section present" \
  || fail "Code editing principles section missing from claude/.claude/CLAUDE.md"

# Agent skills: vault-hosted, wired to both agents by setup.sh
SKILLS_DIR="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/skills"
[[ -L ~/.claude/skills && "$(readlink ~/.claude/skills)" == "$SKILLS_DIR" ]] \
  && pass "~/.claude/skills -> vault skills" \
  || fail "~/.claude/skills not linked to vault skills — run setup.sh"
grep -q 'Documents/skills' ~/.pi/agent/settings.json 2>/dev/null \
  && pass "pi settings include vault skills path" \
  || fail "skills path missing from ~/.pi/agent/settings.json — run setup.sh"
[[ -f "$SKILLS_DIR/wrap-up/SKILL.md" ]] \
  && pass "wrap-up skill present" \
  || fail "wrap-up skill missing — vault not synced or skill deleted"
[[ -f "$SKILLS_DIR/cross-repo-project/SKILL.md" ]] \
  && pass "cross-repo-project skill present" \
  || fail "cross-repo-project skill missing — vault not synced or skill deleted"

# Vault context: session history + curated repo memory + cross-repo specs
VAULT="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents"
SESSION_INDEX="$VAULT/sessions/INDEX.md"
REPO_INDEX="$VAULT/repos/INDEX.md"
PROJECT_INDEX="$VAULT/projects/INDEX.md"
grep -Fq 'updated | scope | repository | workstream | topic | status | doc' "$SESSION_INDEX" 2>/dev/null \
  && pass "handoff index schema" \
  || fail "sessions/INDEX.md missing handoff schema — vault not synced or stale"
grep -Fq 'scope | repository | memory | status' "$REPO_INDEX" 2>/dev/null \
  && pass "repository memory index schema" \
  || fail "repos/INDEX.md missing repository memory schema — vault not synced or stale"
grep -Fq 'scope | workstream | repositories | spec | status' "$PROJECT_INDEX" 2>/dev/null \
  && pass "project index schema" \
  || fail "projects/INDEX.md missing cross-repo schema — vault not synced or stale"
[[ -f "$VAULT/sessions/HANDOFF-TEMPLATE.md" \
  && -f "$VAULT/repos/MEMORY-TEMPLATE.md" \
  && -f "$VAULT/repos/DECISION-TEMPLATE.md" \
  && -f "$VAULT/projects/SPEC-TEMPLATE.md" ]] \
  && pass "agent context templates present" \
  || fail "session/repository/project context template missing — vault not synced or deleted"
grep -Fq 'Under `~/Develop/`' "$AGENT_RULES" && grep -Fq 'Under `~/Develop1/`' "$AGENT_RULES" \
  && pass "work/personal context roots documented" \
  || fail "context roots missing from shared agent rules"
grep -Fq 'Context scope is `work`' ~/Develop/AGENTS.md 2>/dev/null \
  && grep -Fq 'Context scope is `personal`' ~/Develop1/AGENTS.md 2>/dev/null \
  && pass "workspace context scopes" \
  || fail "work/personal workspace scope rules missing"
[[ "$(readlink -f ~/Develop/AGENTS.md)" == "$(readlink -f ~/Develop/CLAUDE.md)" ]] \
  && [[ "$(readlink -f ~/Develop1/AGENTS.md)" == "$(readlink -f ~/Develop1/CLAUDE.md)" ]] \
  && pass "workspace rules shared by pi and Claude Code" \
  || fail "AGENTS.md/CLAUDE.md workspace rules point to different sources"
grep -Fq 'projects/INDEX.md' "$SKILLS_DIR/wrap-up/SKILL.md" \
  && pass "wrap-up skill updates cross-repo state" \
  || fail "wrap-up skill missing cross-repo project step"
grep -Fq 'repos/INDEX.md' "$SKILLS_DIR/wrap-up/SKILL.md" \
  && grep -Fq 'read-only migration sources' "$AGENT_RULES" \
  && pass "wrap-up promotes repo memory; legacy notes read-only" \
  || fail "repository memory promotion or legacy transition rule missing"

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
check_git "core.pager"        "delta --paging=never | less"
check_git "diff.algorithm"    "histogram"
check_git "merge.conflictstyle" "zdiff3"
check_git "alias.vlog"        "log --graph"
check_git "alias.pru"         "fetch --prune"

# ── Docker ────────────────────────────────────────────────────────────────────
section "Docker"
DOCKER=$(zsh -c 'source ~/.zshrc 2>/dev/null; which docker' 2>/dev/null)
if [[ -n "$DOCKER" ]]; then
  pass "docker in PATH ($DOCKER)"
  zsh -c 'source ~/.zshrc 2>/dev/null; docker ps' &>/dev/null \
    && pass "docker daemon reachable" \
    || fail "docker daemon not reachable (macOS: is OrbStack running? Linux: is dockerd running?)"
else
  fail "docker not in PATH (macOS: start OrbStack; Linux: install docker-ce)"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
TOTAL=$((PASS+FAIL))
echo
echo "────────────────────────────────────────"
echo -e "  ${GREEN}${PASS} passed${RESET}  ${RED}${FAIL} failed${RESET}  (${TOTAL} total)"
[[ $FAIL -eq 0 ]]
