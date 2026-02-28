# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Install

```sh
git clone https://github.com/paulyeo21/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup.sh
```

`setup.sh` handles both macOS and Linux:
- Installs Homebrew (macOS) or apt packages (Linux)
- Installs all required tools: `vim`, `tmux`, `fzf`, `ag`, `go`, `pure`
- Removes old symlinks and stows all packages
- Installs zsh-autosuggestions, fzf shell integration, vim-plug, vim plugins, gopls

After setup, verify everything is working:

```sh
./validate.sh
```

## Re-stow after adding files

```sh
cd ~/.dotfiles
stow --target="$HOME" zsh git vim tmux bin
```

## Structure

Each top-level directory is a Stow package mirroring `$HOME`:

| Package | Installs |
|---------|----------|
| `zsh/` | `.zshrc`, `.zshenv`, `.zsh/config/*.zsh` |
| `git/` | `.gitconfig`, `.gitignore_global`, `.git_template/` |
| `vim/` | `.vimrc`, `.vim/{rcfiles,rcplugins,functions}/` |
| `tmux/` | `.tmux.conf` |
| `bin/` | `bin/{git-pr,git-publish,tat}` |

## What's included

**Shell**
- [Pure](https://github.com/sindresorhus/pure) prompt — directory + git branch, async
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) — command suggestions from history
- [fzf](https://github.com/junegunn/fzf) — fuzzy finder wired to `Ctrl+r` (history), `Space+f` (files), `Space+a` (search)
- Vim keybindings in zsh (`bindkey -v`)
- `tm` — fzf session switcher for tmux; `tat` — create/attach session by directory name
- `note` / `notes` — open today's Obsidian daily note in vim

**Vim**
- [vim-go](https://github.com/fatih/vim-go) with gopls — `Space+gd` (definition), `Space+gr` (references), `Space+gi` (implements)
- [vim-fugitive](https://github.com/tpope/vim-fugitive) + [vim-rhubarb](https://github.com/tpope/vim-rhubarb) — `Space+gb` (blame), `Space+go` (open on GitHub)
- [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) — `Ctrl+h/j/k/l` across vim splits and tmux panes
- [fzf.vim](https://github.com/junegunn/fzf.vim), [vim-surround](https://github.com/tpope/vim-surround), [vim-commentary](https://github.com/tpope/vim-commentary)

**Tmux**
- `Ctrl+s` prefix
- `Ctrl+s Ctrl+t` — fzf session picker
- `Ctrl+s Space` — toggle last session
