# ── Git Worktree + Tmux Window Manager ───────────────────────────────────────
wt() {
  if [[ $# -eq 0 ]]; then
    git worktree list
    return
  fi

  if [[ "$1" == "-d" ]]; then
    _wt_remove "${@:2}"
    return
  fi

  _wt_add "$1"
}

_wt_add() {
  local branch="$1"
  local main_root
  main_root="$(git worktree list --porcelain | head -1 | sed 's/^worktree //')"
  local repo_name="${main_root:t}"
  local wt_path="${main_root:h}/${repo_name}-${branch}"

  if [[ -d "$wt_path" ]]; then
    echo "Worktree already exists at $wt_path"
  else
    if git show-ref --verify --quiet "refs/heads/$branch" 2>/dev/null || \
       git show-ref --verify --quiet "refs/remotes/origin/$branch" 2>/dev/null; then
      git worktree add "$wt_path" "$branch" || return 1
    else
      git worktree add "$wt_path" -b "$branch" || return 1
    fi
  fi

  if [[ -n "$TMUX" ]]; then
    tmux new-window -n "$branch" -c "$wt_path"
  else
    cd "$wt_path" || return 1
  fi
}

_wt_remove() {
  local branch="$1"
  if [[ -z "$branch" ]]; then
    echo "Usage: wt -d <branch>"
    return 1
  fi

  local main_root
  main_root="$(git worktree list --porcelain | head -1 | sed 's/^worktree //')"
  local repo_name="${main_root:t}"
  local wt_path="${main_root:h}/${repo_name}-${branch}"

  # Kill tmux window if it exists
  if [[ -n "$TMUX" ]]; then
    local win_id
    win_id="$(tmux list-windows -F '#{window_name}:#{window_id}' | grep "^${branch}:" | cut -d: -f2)"
    if [[ -n "$win_id" ]]; then
      tmux kill-window -t "$win_id"
    fi
  fi

  git worktree remove "$wt_path" 2>/dev/null || git worktree remove --force "$wt_path"
}
