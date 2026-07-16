#!/usr/bin/env zsh
set -eu

ROOT="$(mktemp -d)"
trap 'cd /; rm -rf "$ROOT"' EXIT

configure_repo() {
  git -C "$1" config user.email test@example.com
  git -C "$1" config user.name "wt test"
}

# Local submodule source.
git init -q "$ROOT/submodule"
configure_repo "$ROOT/submodule"
echo tracked > "$ROOT/submodule/tracked.txt"
git -C "$ROOT/submodule" add tracked.txt
git -C "$ROOT/submodule" commit -qm init

# Superproject with one submodule.
git init -q "$ROOT/main"
configure_repo "$ROOT/main"
echo main > "$ROOT/main/main.txt"
git -C "$ROOT/main" add main.txt
git -C "$ROOT/main" commit -qm init
git -C "$ROOT/main" -c protocol.file.allow=always submodule add -q \
  "$ROOT/submodule" modules/sample
git -C "$ROOT/main" commit -qam "add submodule"

source "${0:A:h:h}/zsh/.zsh/config/worktree.zsh"
TMUX=""

# Clean initialized submodule: wt must use Git's required --force internally.
git -C "$ROOT/main" worktree add -qb clean-submodule "$ROOT/clean-submodule"
git -C "$ROOT/clean-submodule" -c protocol.file.allow=always \
  submodule update --init -q
cd "$ROOT/clean-submodule"
wt done >/dev/null
[[ ! -d "$ROOT/clean-submodule" ]]
! git -C "$ROOT/main" show-ref --verify --quiet refs/heads/clean-submodule

# Uninitialized submodule: normal removal remains unchanged.
git -C "$ROOT/main" worktree add -qb uninitialized "$ROOT/uninitialized"
cd "$ROOT/uninitialized"
wt done >/dev/null
[[ ! -d "$ROOT/uninitialized" ]]
! git -C "$ROOT/main" show-ref --verify --quiet refs/heads/uninitialized

# Dirty initialized submodule: wt must refuse and preserve worktree + branch.
git -C "$ROOT/main" worktree add -qb dirty-submodule "$ROOT/dirty-submodule"
git -C "$ROOT/dirty-submodule" -c protocol.file.allow=always \
  submodule update --init -q
echo dirty > "$ROOT/dirty-submodule/modules/sample/untracked.txt"
cd "$ROOT/dirty-submodule"
if wt done >/dev/null 2>&1; then
  echo "wt removed a worktree with a dirty submodule" >&2
  exit 1
fi
[[ -d "$ROOT/dirty-submodule" ]]
git -C "$ROOT/main" show-ref --verify --quiet refs/heads/dirty-submodule

# Test cleanup (not behavior under test).
rm "$ROOT/dirty-submodule/modules/sample/untracked.txt"
cd "$ROOT/main"
git worktree remove --force "$ROOT/dirty-submodule"
git branch -D dirty-submodule >/dev/null

print "worktree submodule cleanup tests passed"
