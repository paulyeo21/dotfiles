# ── Git Worktree + Tmux Window Manager ───────────────────────────────────────
wt() {
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<'EOF'
wt — git worktree + tmux window manager

Usage: wt              list worktrees
       wt <branch>     add worktree at ../<repo>-<branch>, open tmux window
       wt done         finish the worktree you're in: remove it, delete the
                       branch if merged, close its tmux window
       wt -d <branch>  same cleanup for a named worktree

Removal refuses worktrees with uncommitted changes (no silent --force).
EOF
    return 0
  fi

  if [[ $# -eq 0 ]]; then
    git worktree list
    return
  fi

  if [[ "$1" == "-d" ]]; then
    _wt_remove "${@:2}"
    return
  fi

  if [[ "$1" == "done" ]]; then
    _wt_done
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

# Resolve the worktree path that has <branch> checked out
_wt_path_for_branch() {
  git worktree list --porcelain | awk -v b="branch refs/heads/$1" '
    /^worktree / { path = substr($0, 10) }
    $0 == b     { print path; exit }'
}

# Finish the worktree we're currently inside
_wt_done() {
  local top main_root branch
  top="$(git rev-parse --show-toplevel 2>/dev/null)"
  if [[ -z "$top" ]]; then
    echo "Not in a git repo"
    return 1
  fi
  main_root="$(git worktree list --porcelain | head -1 | sed 's/^worktree //')"
  if [[ "$top" == "$main_root" ]]; then
    echo "This is the main checkout — wt done only runs inside a linked worktree"
    return 1
  fi
  branch="$(git -C "$top" rev-parse --abbrev-ref HEAD)"
  if [[ "$branch" == "HEAD" ]]; then
    echo "Detached HEAD — remove manually with: git worktree remove $top"
    return 1
  fi
  _wt_finish "$top" "$branch" "current"
}

_wt_remove() {
  local branch="$1"
  if [[ -z "$branch" ]]; then
    echo "Usage: wt -d <branch>"
    return 1
  fi

  local wt_path
  wt_path="$(_wt_path_for_branch "$branch")"
  if [[ -z "$wt_path" ]]; then
    echo "No worktree has branch $branch checked out (run wt to list)"
    return 1
  fi

  _wt_finish "$wt_path" "$branch" ""
}

# Shared cleanup: remove worktree, delete merged branch, close tmux window.
# $3 non-empty = finishing the window we are in (kill it last).
_wt_finish() {
  local wt_path="$1" branch="$2" kill_current="$3"
  local main_root
  main_root="$(git worktree list --porcelain | head -1 | sed 's/^worktree //')"

  # Refuse dirty worktrees — never silently --force
  if [[ -n "$(git -C "$wt_path" status --porcelain)" ]]; then
    echo "Uncommitted changes in $wt_path — commit or stash first"
    echo "(or: git worktree remove --force $wt_path)"
    return 1
  fi

  # Step out if we're inside the worktree being removed (:A resolves
  # symlinks — git reports physical paths, $PWD may not be)
  if [[ "${PWD:A}" == "${wt_path:A}" || "${PWD:A}" == "${wt_path:A}/"* ]]; then
    cd "$main_root" || return 1
  fi

  # Remove the worktree BEFORE killing any window: killing our own window
  # would take the shell (and this cleanup) down with it
  git -C "$main_root" worktree remove "$wt_path" || return 1

  # git branch -d prints its own "Deleted branch ..." on success
  if ! git -C "$main_root" branch -d "$branch" 2>/dev/null; then
    echo "Branch $branch kept (unmerged — delete with: git branch -D $branch)"
  fi

  # Kill the tmux window last; it may be the one we're in
  if [[ -n "$TMUX" ]]; then
    if [[ -n "$kill_current" ]]; then
      tmux kill-window
    else
      local win_id
      win_id="$(tmux list-windows -F '#{window_name}:#{window_id}' | grep "^${branch}:" | cut -d: -f2)"
      if [[ -n "$win_id" ]]; then
        tmux kill-window -t "$win_id"
      fi
    fi
  fi
}
