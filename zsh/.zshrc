# 1. Config files (completion.zsh runs compinit -u first, alphabetically)
for f in ~/.zsh/config/*.zsh; do source "$f"; done

# 2. Tool init (compinit has run, compdef is available)
eval "$(rbenv init - --no-rehash zsh)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
export PATH="$(go env GOPATH)/bin:$PATH"

# 3. NVM (interactive only; single source from Homebrew path)
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && source "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && source "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# 4. Plugins
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# 5. Local overrides (machine-specific, gitignored)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
