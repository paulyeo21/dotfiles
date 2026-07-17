# 1. Config files (completion.zsh runs compinit -u first, alphabetically)
for f in ~/.zsh/config/*.zsh; do source "$f"; done

# 2. Tool init (compinit has run, compdef is available)
command -v rbenv &>/dev/null && eval "$(rbenv init - --no-rehash zsh)"

# 3. NVM (interactive only; default Node version pinned via `nvm alias default 22` in setup.sh)
export NVM_DIR="$HOME/.nvm"
if [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
  # macOS: Homebrew formula
  source "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && source "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
elif [ -s "$NVM_DIR/nvm.sh" ]; then
  # Linux: installed via official script into $NVM_DIR
  source "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
fi

# 4. OrbStack (docker, kubectl — init is in .zprofile for login shells; repeat here for non-login)
[[ -f ~/.orbstack/shell/init.zsh ]] && source ~/.orbstack/shell/init.zsh 2>/dev/null

# 5. Plugins
[[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# 6. Local overrides (machine-specific, gitignored)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
eval "$( direnv hook zsh )"
