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

# New names use the personal namespace while retaining the requested path.
cd "$ROOT/main"
wt personal-topic >/dev/null
[[ "${PWD:A}" == "${ROOT:A}/main-personal-topic" ]]
[[ "$(git branch --show-current)" == "paulyeo/personal-topic" ]]
wt -d personal-topic <<< y >/dev/null
[[ ! -d "$ROOT/main-personal-topic" ]]
! git -C "$ROOT/main" show-ref --verify --quiet \
  refs/heads/paulyeo/personal-topic

# Existing local branch names remain unchanged.
git -C "$ROOT/main" branch existing-topic
cd "$ROOT/main"
wt existing-topic >/dev/null
[[ "$(git branch --show-current)" == "existing-topic" ]]
wt done <<< y >/dev/null

# Existing origin branch names also remain unchanged.
git init -q --bare "$ROOT/remote"
git -C "$ROOT/main" remote add origin "$ROOT/remote"
git -C "$ROOT/main" push -q origin HEAD:refs/heads/remote-topic
git -C "$ROOT/main" fetch -q origin \
  refs/heads/remote-topic:refs/remotes/origin/remote-topic
cd "$ROOT/main"
wt remote-topic >/dev/null
[[ "$(git branch --show-current)" == "remote-topic" ]]
wt done <<< y >/dev/null

# Confirmed removal handles a clean initialized submodule.
git -C "$ROOT/main" worktree add -qb clean-submodule "$ROOT/clean-submodule"
git -C "$ROOT/clean-submodule" -c protocol.file.allow=always \
  submodule update --init -q
cd "$ROOT/clean-submodule"
wt done <<< y >/dev/null
[[ ! -d "$ROOT/clean-submodule" ]]
! git -C "$ROOT/main" show-ref --verify --quiet refs/heads/clean-submodule

# Confirmed removal also handles an uninitialized submodule.
git -C "$ROOT/main" worktree add -qb uninitialized "$ROOT/uninitialized"
cd "$ROOT/uninitialized"
wt done <<< y >/dev/null
[[ ! -d "$ROOT/uninitialized" ]]
! git -C "$ROOT/main" show-ref --verify --quiet refs/heads/uninitialized

# Declining confirmation preserves a dirty worktree and branch.
git -C "$ROOT/main" worktree add -qb dirty-submodule "$ROOT/dirty-submodule"
git -C "$ROOT/dirty-submodule" -c protocol.file.allow=always \
  submodule update --init -q
echo dirty > "$ROOT/dirty-submodule/modules/sample/untracked.txt"
cd "$ROOT/dirty-submodule"
if wt done <<< n >/dev/null 2>&1; then
  echo "wt ignored declined removal confirmation" >&2
  exit 1
fi
[[ -d "$ROOT/dirty-submodule" ]]
git -C "$ROOT/main" show-ref --verify --quiet refs/heads/dirty-submodule

# Confirming permanently removes the dirty worktree and its merged branch.
wt done <<< y >/dev/null
[[ ! -d "$ROOT/dirty-submodule" ]]
! git -C "$ROOT/main" show-ref --verify --quiet refs/heads/dirty-submodule

# Leftover administrative metadata from a deinitialized submodule also needs
# confirmed force removal. Files hidden from Git status are discarded.
git -C "$ROOT/main" worktree add -qb deinitialized "$ROOT/deinitialized"
git -C "$ROOT/deinitialized" -c protocol.file.allow=always \
  submodule update --init -q
git -C "$ROOT/deinitialized" submodule --quiet deinit -f -- modules/sample
echo hidden > "$ROOT/deinitialized/modules/sample/hidden.txt"
cd "$ROOT/deinitialized"
wt done <<< yes >/dev/null
[[ ! -d "$ROOT/deinitialized" ]]
! git -C "$ROOT/main" show-ref --verify --quiet refs/heads/deinitialized

print "worktree tests passed"
