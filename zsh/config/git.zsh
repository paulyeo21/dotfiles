
# No arguments: `git status`
# With arguments: acts like `git`
g() {
	if [[ $# > 0 ]]; then
		git $@
	else
		git status
	fi
}

# Complete go like git
compdef g=git
