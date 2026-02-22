# 1. Config files (completion.zsh runs compinit -u first, alphabetically)
for f in ~/.zsh/config/*.zsh; do source "$f"; done

# 2. Tool init (compinit has run, compdef is available)
command -v rbenv &>/dev/null && eval "$(rbenv init - --no-rehash zsh)"
command -v pyenv &>/dev/null && eval "$(pyenv init -)"
command -v pyenv &>/dev/null && eval "$(pyenv virtualenv-init -)"
command -v go    &>/dev/null && export PATH="$(go env GOPATH)/bin:$PATH"

# 3. NVM (interactive only; single source from Homebrew path)
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && source "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && source "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# 4. OrbStack (docker, kubectl — init is in .zprofile for login shells; repeat here for non-login)
[[ -f ~/.orbstack/shell/init.zsh ]] && source ~/.orbstack/shell/init.zsh 2>/dev/null

# 5. Plugins
[[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# 6. Local overrides (machine-specific, gitignored)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
