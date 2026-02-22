# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Install

```sh
git clone https://github.com/paulyeo21/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup.sh
```

`setup.sh` installs Homebrew (macOS) or apt packages (Linux), installs Stow, removes any pre-existing symlinks, and stows all packages.

## Re-stow after adding files

```sh
cd ~/.dotfiles
stow --target="$HOME" zsh git vim tmux bin
```

## Validate

```sh
./validate.sh
```

Runs 38 smoke tests across symlinks, file existence, permissions, shell aliases/functions, and git config.

## Structure

Each top-level directory is a Stow package mirroring `$HOME`:

| Package | Installs |
|---------|----------|
| `zsh/` | `.zshrc`, `.zshenv`, `.zsh/config/*.zsh` |
| `git/` | `.gitconfig`, `.gitignore_global`, `.git_template/` |
| `vim/` | `.vimrc`, `.vim/{rcfiles,rcplugins,functions}/` |
| `tmux/` | `.tmux.conf` |
| `bin/` | `bin/{git-pr,git-publish,tat}` |
