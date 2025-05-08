# No arguments: `git status`
# With arguments: acts like `git`
function g() {
  if [[ "$1" == "pru" ]]; then
    git fetch --prune && \
    git branch --merged | grep -vE "^\*|main|master" | xargs -r git branch -d && \
    git branch -vv | awk '/: gone]/{print $1}' | xargs -r git branch -D
	elif [[ $# > 0 ]]; then
		git $@
	else
		git status
	fi
}

# Complete g like git
compdef g="git"
