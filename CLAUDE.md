# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Installation

```sh
./setup.sh
```

Installs Homebrew (macOS) / apt packages (Linux), installs [GNU Stow](https://www.gnu.org/software/stow/), removes any old symlinks, then stows all packages. To re-stow after adding files:

```sh
cd ~/.dotfiles
stow --target="$HOME" zsh git vim tmux bin
```

## Architecture

This is a GNU Stow-managed dotfiles repo. Each top-level directory is a **stow package** whose contents mirror `$HOME`. Running `stow <package>` creates symlinks from `$HOME` into the package directory.

```
~/.dotfiles/
  zsh/      → stow package: .zshrc, .zshenv, .zsh/config/*.zsh
  git/      → stow package: .gitconfig, .gitignore_global, .git_template/
  vim/      → stow package: .vimrc, .vim/{rcfiles,rcplugins,functions}/
  tmux/     → stow package: .tmux.conf
  bin/      → stow package: bin/{git-pr,git-publish,tat}
```

**Zsh load order** (important for correctness):
1. `.zshenv` — PATH and env vars only, no interactive tool init. Sourced for every shell including scripts.
2. `.zshrc` — all interactive setup in this order:
   - `~/.zsh/config/*.zsh` (sourced alphabetically; `completion.zsh` runs `compinit -u` first)
   - rbenv / pyenv / Go init (need `compdef`, so must come after `completion.zsh`)
   - NVM (interactive only, sourced from Homebrew path)
   - Plugins: zsh-autosuggestions, fzf
   - `~/.zshrc.local` if present (machine-specific overrides, gitignored)

**Vim:** `vim/.vimrc` uses vim-plug and dynamically loads from `~/.vim/{rcplugins,rcfiles,functions}/`. Plugins are installed in `~/.vim/bundle/` (gitignored).

**Git hooks:** `git/.git_template/hooks/` contains post-checkout/commit/merge/rewrite hooks that regenerate ctags.
