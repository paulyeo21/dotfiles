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

## Portability invariant (read before adding anything new)

**`setup.sh` is the single source of truth for provisioning a new machine.** Any change that introduces an external dependency must be reflected in `setup.sh` *and* covered by `validate.sh` in the same commit. If a fresh `./setup.sh && ./validate.sh` on a clean machine wouldn't reproduce the workflow, the change is incomplete.

Checklist for any new dependency or workflow change:

1. **Install** — add the package to the `brew install` line (macOS) and `apt-get install` line (Linux) in `setup.sh`. If the tool isn't packaged, add an explicit install block (see the `go` / `pure` blocks for the pattern).
2. **Configure** — put the config in the appropriate stow package (`git/`, `zsh/`, `vim/`, etc.) so `stow` picks it up. Never write config to `$HOME` directly.
3. **Symlink** — if it adds a new symlink target, append it to the cleanup loop in `setup.sh`.
4. **Verify** — add a `check_cmd` (for binaries) or `check_git` / `grep` check (for config keys) to `validate.sh`.
5. **Document** — add a row to the relevant table in this file, or a bullet under Conventions / Common pitfalls if it changes behavior.

Rule of thumb: if the change isn't in `setup.sh` + `validate.sh` + (this file when behavior changes), it doesn't exist.

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
  workspaces/→ Develop{,1}/{AGENTS.md,CLAUDE.md}
```

**Global agent rules** live in `claude/.claude/CLAUDE.md`. `setup.sh`
symlinks that file to two places so both agents read it:
- `~/.claude/CLAUDE.md` — Claude Code (via stow)
- `~/.pi/agent/AGENTS.md` — pi (direct `ln -sf` after stow, since it's a single file)

When editing rules, edit `claude/.claude/CLAUDE.md` only; both agents pick
up the change on next session start (`/reload` in pi).

**Agent skills** live in the Obsidian vault (`$VAULT/skills/<name>/SKILL.md`)
so they're reviewable/editable in Obsidian, including mobile. `setup.sh`
wires them to both agents: `~/.claude/skills` symlink (Claude Code) and a
`skills` array in `~/.pi/agent/settings.json` (pi — idempotent python merge,
since that file holds mutable pi state and can't be stowed). The skill
files themselves are backed up by iCloud, not git. Shared skills currently
include `wrap-up` (finalize handoffs and promote knowledge) and
`cross-repo-project` (create/maintain an indexed multi-repo source of truth).

**Agent context docs** also live in the vault. Selective workstream handoffs
under `sessions/{work,personal}/` preserve unfinished state; completed
self-contained work creates no receipt, and only open handoffs load
automatically. Curated repository truths and ADR-style decisions live under
`repos/<scope>/<host>/<owner>/<repo>/` and
are routed by `repos/INDEX.md`. Cross-repo source-of-truth specs live under
`projects/{work,personal}/` and are routed by `projects/INDEX.md`. Legacy
repo-root `implementation-notes.md` files are read-only migration sources.
`~/Develop/` is work and `~/Develop1/` is personal. Their inherited
workspace rules are stowed from `workspaces/{Develop,Develop1}/AGENTS.md`;
each sibling `CLAUDE.md` symlinks to that same source so pi and Claude Code
inherit identical rules. Repo-level context files add commands and
conventions on top.

**Zsh load order** (important for correctness):
1. `.zshenv` — PATH and env vars only, no interactive tool init
2. `.zshrc` — interactive setup:
   - `~/.zsh/config/*.zsh` (alphabetically; `completion.zsh` runs `compinit -u` first)
   - rbenv init (needs `compdef`, so must come after `completion.zsh`)
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

## Shell keybindings & history

- `Ctrl+R` — reverse history search (fzf when `~/.fzf.zsh` is loaded; otherwise zsh built-in).
- `Ctrl+P` / `Ctrl+N` — previous/next history line (vim mode wipes these, restored in `config/keybindings.zsh`).
- History policy: `hist_ignore_dups` + `hist_find_no_dups`, **not** `hist_ignore_all_dups`. The latter deletes every earlier copy of a command on each re-run — it silently shrinks history and makes `Ctrl+R` look broken. `HISTSIZE`/`SAVEHIST` = 100k. Leading-space commands are kept out of history (`hist_ignore_space`).

## Shell functions & aliases

| Command | Description | File |
|---------|-------------|------|
| `g` | Git wrapper (status if no args) | config/git.zsh |
| `tm [name]` | fzf tmux session switcher | config/tmux.zsh |
| `wb [sdk] <prod\|qa\|dev> script.py` | Run wandb script with env | config/alias.zsh |
| `wbdb <prod\|qa\|dev> [flat\|usage]` | Connect to wandb MySQL | config/alias.zsh |
| `note` | Edit today's Obsidian note | config/alias.zsh |
| `topic file.md ...` | Copy md files to vault topics/ (mobile via iCloud) | config/alias.zsh |
| `dot` | Fuzzy-search these reference tables (fzf) | config/alias.zsh |
| `notes` | Open Obsidian vault in fzf | config/alias.zsh |
| `tat [name]` | Attach/create tmux session by dir name | bin/tat |
| `wt [branch\|done\|-d branch]` | Git worktree + tmux window manager | config/worktree.zsh |

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

**Adding a shell function:** Functions that take arguments get a `-h|--help` block at the top printing a usage heredoc (see `wb` in `config/alias.zsh` for the pattern). Error paths reuse it: `myfn --help >&2; return 1`. Add a row to the functions table above.

**Adding a vim plugin:** Add `Plug '...'` in a file under `vim/.vim/rcplugins/`. Add keybindings in the same file. Run `:PlugInstall`.

**Adding a vim keybinding:** Use `nnoremap` (not `map`). Add to `vim/.vim/rcfiles/mappings` or the relevant rcfiles/ topic file. Check the keybinding table above to avoid conflicts.

**Adding a git alias:** Add to the appropriate section in `git/.gitconfig` under `[alias]`.

**Adding a system dependency:** Follow the Portability invariant checklist above — `setup.sh` (install) + stow package (config) + `validate.sh` (verify) + this file (docs).

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
- **Claude Code scroll inside tmux** — Claude defaults to fullscreen/alt-screen rendering. tmux scrollback shows pre-session content (not the conversation). Use `PageUp`/`PageDown` inside Claude for in-session scroll, or `Ctrl+O` then `[` to dump a clean transcript to scrollback. Do NOT export `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1` — inline mode causes scrollback to fill with repeated redraw frames during streaming.
- **Node default is pinned to v22 via nvm** — `setup.sh` runs `nvm install 22 && nvm alias default 22`. To change, bump both calls in `setup.sh` and the v22 check in `validate.sh`. nvm itself is installed via `brew install nvm` on macOS and the official curl script on Linux.
- **brew calls wrap with `cd "$HOME"`** — Homebrew's pwd-readability check fails inside iCloud-synced dirs (e.g., Obsidian vault) even when Unix perms look fine. `.zshenv` and `completion.zsh` wrap their brew invocations so a fresh shell started in such a dir doesn't crash. Keep this pattern for any new brew call in shell init.
- **`git diff` is piped through `delta`** — `core.pager = delta` in `.gitconfig`. Use `n`/`N` inside the pager to jump between files. Disable per-invocation with `git --no-pager diff` if needed for scripts.

## Workflow

After completing any task, always ask the user if they want to commit and push the changes.
