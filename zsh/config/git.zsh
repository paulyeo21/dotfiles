
# No arguments: `git status`
# With arguments: acts like `git`
function g() {
	if [[ $# > 0 ]]; then
		git $@
  elif [[ "$1" == "prune" ]]; then
    git fetch --prune && \                                                         # removes stale remote-tracking branches
    git branch --merged | grep -vE "^\*|main|master" | xargs -r git branch -d && \ # lists local branches that are fully merged
    git branch -vv | awk '/: gone]/{print $1}' | xargs -r git branch -D            # deletes local branches whose remotes are gone
	else
		git status
	fi
}

# Complete g like git
compdef g="git"
