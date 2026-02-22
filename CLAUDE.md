# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Installation

```sh
# macOS
./setup-macos.sh

# Linux
./setup-linux.sh
```

Both scripts install dependencies, create symlinks from `~` to the repo files, set up zsh with autosuggestions, install vim-plug + plugins, and configure tmux plugin manager.

## Architecture

This is a personal dotfiles repository for macOS/Linux. Symlinks are created from `~/.<name>` to the files here.

**Shell (Zsh):**
- `zsh/zshrc` — entry point; sources all files in `zsh/config/`
- `zsh/zshenv` — PATH and tool initialization (Homebrew, pyenv, rbenv, nvm, go, java, mysql, postgres, rust)
- `zsh/config/` — modular config files: `alias.zsh`, `git.zsh`, `keybindings.zsh`, `history.zsh`, `tmux.zsh`, `completion.zsh`, etc.
- `zsh/cjt.zsh-theme` — custom prompt theme

**Vim:**
- `vim/vimrc` — entry point using vim-plug; dynamically loads from `rcplugins/`, `rcfiles/`, `functions/`
- `vim/rcplugins/` — one file per plugin declaration
- `vim/rcfiles/` — settings files (`general`, `mappings`, `golang`, `python`, `search-and-replace`)
- `vim/functions/` — custom Vim functions
- Leader key is `<Space>`

**Git:**
- `git/gitconfig` — aliases, editor (vim), LFS, merge tool settings
- `git/gitignore_global` — global ignores
- `git/git_template/hooks/` — post-checkout/commit/merge/rewrite hooks that regenerate ctags

**Tmux:**
- `tmux/tmux.conf` — prefix is `Ctrl-s`; splits with `\` (vertical) and `-` (horizontal); vim-tmux navigator integration

**Bin scripts:**
- `bin/git-pr` — opens GitHub PR page for current branch
- `bin/git-publish` — pushes branch and sets upstream
- `bin/tat` — attaches to a tmux session named after the current directory
- `bin/kgp`, `bin/kgd` — kubectl shortcuts
