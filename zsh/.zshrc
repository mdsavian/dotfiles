# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

eval "$(zoxide init zsh)"

plugins=(
  git
  asdf
  tmux
  fzf
  vi-mode
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

autoload -Uz compinit
compinit

# Show a selectable menu when completing
zstyle ':completion:*' menu yes select

# Do not reorder zoxide results when completing `z`
zstyle ':completion:*:*:z:*' sort false

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH=$PATH:/usr/local/go/bin


# alternative aws alias
alias ssodev='aws sso login --profile dev'
alias ssoprod='aws sso login --profile prod'
alias k9sprod='kubectx prod && k9s'
alias k9sstg='kubectx staging && k9s'
alias k9sdemo='kubectx demo && k9s'

rdsstaging() {
    genpass rdsdbstaging.cjg7xp1zczeo.us-east-1.rds.amazonaws.com dev
}

rdsdemo() {
    genpass rdsdbsdemo.cjg7xp1zczeo.us-east-1.rds.amazonaws.com dev
}

rdsprod() {
    genpass rdsdbprod.cnfynuntdlwf.us-east-1.rds.amazonaws.com prod
}

genpass() {
    PASS="$(aws rds generate-db-auth-token --hostname $1 --port 5432 --region us-east-1 --username marlon@alternativepayments.io --profile $2)"
    printf "%s" "$PASS" | pbcopy
    echo "Password copied to clipboard"
}

# git alias
alias gcdp='git checkout development && git pull'
alias gcmp='git checkout main && git pull'

# zoxide alias
alias z='zi'

# postgresql
export PATH="/opt/homebrew/opt/postgresql@18/bin:$PATH"

export PATH="$HOME/go/bin:$PATH"


# Claude alias
alias claudio='claude --dangerously-skip-permissions'
# Codex alias
alias kodex='codex --dangerously-bypass-approvals-and-sandbox'
