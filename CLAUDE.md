# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Installation

```sh
./setup.sh
```

Installs Homebrew (macOS) / apt packages (Linux), installs [GNU Stow](https://www.gnu.org/software/stow/), removes any old symlinks, then stows all packages. To re-stow after adding files:

```sh
cd ~/.dotfiles
stow --target="$HOME" zsh git vim tmux bin claude alacritty
```

## Architecture

This is a GNU Stow-managed dotfiles repo. Each top-level directory is a **stow package** whose contents mirror `$HOME`. Running `stow <package>` creates symlinks from `$HOME` into the package directory.

```
~/.dotfiles/
  zsh/      → .zshrc, .zshenv, .zsh/config/*.zsh
  git/      → .gitconfig, .gitignore_global, .git_template/
  vim/      → .vimrc, .vim/{rcfiles,rcplugins,functions}/
  tmux/     → .tmux.conf
  bin/      → bin/{git-pr,git-publish,tat}
  claude/   → .claude/CLAUDE.md, .claude/settings.json
  alacritty/→ .config/alacritty/alacritty.toml
```

**Zsh load order** (important for correctness):
1. `.zshenv` — PATH and env vars only, no interactive tool init
2. `.zshrc` — interactive setup:
   - `~/.zsh/config/*.zsh` (alphabetically; `completion.zsh` runs `compinit -u` first)
   - rbenv / pyenv / Go init (need `compdef`, so must come after `completion.zsh`)
   - NVM, OrbStack
   - Plugins: zsh-autosuggestions, fzf (`~/.fzf.zsh`)
   - `~/.zshrc.local` (machine-specific, gitignored)

**Vim:** `vim/.vimrc` uses vim-plug; dynamically loads from `~/.vim/{rcplugins,rcfiles,functions}/`. Plugins installed in `~/.vim/bundle/` (gitignored).

**Git hooks:** `git/.git_template/hooks/` — post-checkout/commit/merge/rewrite hooks for ctags regeneration.

## Vim keybindings (leader = Space)

These are already mapped — do NOT remap without checking for conflicts:

| Key | Action | File |
|-----|--------|------|
| `<leader>f` | fzf Files | rcplugins/fzf |
| `<leader>a` | fzf Ag (text search) | rcplugins/fzf |
| `<leader>gb` | Git blame | rcplugins/fugitive |
| `<leader>go` | Open in GitHub | rcplugins/fugitive |
| `<leader>gd` | Go definition (gopls) | rcfiles/golang |
| `<leader>gi` | Go implements (gopls) | rcfiles/golang |
| `<leader>gr` | Go referrers (gopls) | rcfiles/golang |
| `<leader>gk` | Go info (gopls) | rcfiles/golang |
| `<leader>so` | Source vimrc + doautocmd FileType | rcfiles/mappings |
| `<leader>e` | Edit file in current dir | rcfiles/mappings |
| `<leader>t` | Tab edit in current dir | rcfiles/mappings |
| `<leader>p` | Paste from clipboard | rcfiles/mappings |
| `<leader>cp` | Copy entire file to clipboard | rcfiles/mappings |
| `<leader>mv` | Rename current file | rcfiles/mappings |
| `<leader>cc` | Close quickfix | rcfiles/mappings |
| `<leader>sub` | Search & replace prompt | rcfiles/search-and-replace |
| `<leader>h` | Clear search highlight | rcfiles/search-and-replace |
| `]q` / `[q` | Next/prev quickfix entry | rcfiles/mappings |
| `:Note` | Open today's Obsidian daily note | rcfiles/mappings |

## Shell functions & aliases

| Command | Description | File |
|---------|-------------|------|
| `g` | Git wrapper (status if no args) | config/git.zsh |
| `tm [name]` | fzf tmux session switcher | config/tmux.zsh |
| `wb [sdk] <prod\|qa\|dev> script.py` | Run wandb script with env | config/alias.zsh |
| `wbdb <prod\|qa\|dev> [flat\|usage]` | Connect to wandb MySQL | config/alias.zsh |
| `note` | Edit today's Obsidian note | config/alias.zsh |
| `notes` | Open Obsidian vault in fzf | config/alias.zsh |
| `tat [name]` | Attach/create tmux session by dir name | bin/tat |

## Git aliases

Defined in `git/.gitconfig` under `[alias]`, grouped by section:
- **Status**: `st`, `d`, `dc`
- **Staging**: `aa`, `uncommit`
- **Branching**: `co`, `b`, `del`, `delr`, `rename`
- **Syncing**: `f`, `pru`, `mup` (detects main vs master), `reseto`
- **Remotes**: `rv`
- **Log**: `vlog`, `glog`

## Conventions

**Adding zsh config:** Create or edit a file in `zsh/.zsh/config/`. Files are sourced alphabetically — name matters for load order.

**Adding a vim plugin:** Add `Plug '...'` in a file under `vim/.vim/rcplugins/`. Add keybindings in the same file. Run `:PlugInstall`.

**Adding a vim keybinding:** Use `nnoremap` (not `map`). Add to `vim/.vim/rcfiles/mappings` or the relevant rcfiles/ topic file. Check the keybinding table above to avoid conflicts.

**Adding a git alias:** Add to the appropriate section in `git/.gitconfig` under `[alias]`.

## Testing

After any changes, run:

```sh
./validate.sh    # 50+ checks: symlinks, binaries, zsh, vim, tmux, git, claude, docker
```

## Common pitfalls

- **Use `nnoremap`, not `map`** — `map` applies to all modes and can cause recursive mappings.
- **vim-go uses quickfix** — `let g:go_list_type = "quickfix"` is set. Navigate with `]q`/`[q`, not `:lnext`.
- **Go auto-save uses `noautocmd write`** — skips goimports to prevent quickfix line drift on InsertLeave.
- **`doautocmd FileType` after sourcing vimrc** — without this, filetype-specific autocmds won't re-fire (indent breaks).
- **fzf integration** — generated via `fzf --zsh > ~/.fzf.zsh` (cross-platform). Don't use brew-specific install paths.
- **`bindkey -v` removes emacs bindings** — Ctrl+p/n/w/u are explicitly restored in `config/keybindings.zsh`.
- **Tmux prefix is Ctrl+s** — not the default Ctrl+b. Resurrect: `Ctrl+s S` (save), `Ctrl+s R` (restore).

## Workflow

After completing any task, always ask the user if they want to commit and push the changes.
