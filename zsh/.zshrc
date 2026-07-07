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

# git alias
alias gcdp='git checkout development && git pull'
alias gcmp='git checkout main && git pull'

# zoxide alias
alias z='zi'

alias claudio='claude --dangerously-skip-permissions'

# Local bin (personal scripts, e.g. `wt`)
export PATH="$HOME/.local/bin:$PATH"

# wt: pooled git worktree tool (~/.local/bin/wt) — cd on go/create, passthrough otherwise
wt() {
  case "$1" in
    go|create)
      local target
      target=$(command wt "$@") && cd "$target"
      ;;
    *)
      command wt "$@"
      ;;
  esac
}

# Machine-local secrets / env (not committed — see ~/.zshrc.local)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# Enable GPG SSH agent support
# https://www.gnupg.org/documentation/manuals/gnupg/Agent-Examples.html
unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
  export SSH_AUTH_SOCK
  SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi

# Configure GPG terminal device file (TTY)
export GPG_TTY
GPG_TTY="$(tty)"

# Set the startup TTY and X-DISPLAY variables to the values of this session
# https://www.gnupg.org/documentation/manuals/gnupg/Agent-UPDATESTARTUPTTY.html
gpg-connect-agent updatestartuptty /bye 1> /dev/null


[[ -s "/Users/marlon.savian/.gvm/scripts/gvm" ]] && source "/Users/marlon.savian/.gvm/scripts/gvm"
source ~/.gvm/scripts/gvm
# BEGIN_AWS_SSO_CLI

# AWS SSO requires `bashcompinit` which needs to be enabled once and
# only once in your shell.  Hence we do not include the two lines:
#
# autoload -Uz +X compinit && compinit
# autoload -Uz +X bashcompinit && bashcompinit
#
# If you do not already have these lines, you must COPY the lines 
# above, place it OUTSIDE of the BEGIN/END_AWS_SSO_CLI markers
# and of course uncomment it

__aws_sso_profile_complete() {
     local _args=${AWS_SSO_HELPER_ARGS:- -L error}
    _multi_parts : "($(/Users/marlon.savian/.gvm/pkgsets/go1.23.2/global/bin/aws-sso ${=_args} list --csv Profile))"
}

aws-sso-profile() {
    local _args=${AWS_SSO_HELPER_ARGS:- -L error}
    if [ -n "$AWS_PROFILE" ]; then
        echo "Unable to assume a role while AWS_PROFILE is set"
        return 1
    fi

    if [ -z "$1" ]; then
        echo "Usage: aws-sso-profile <profile>"
        return 1
    fi

    eval $(/Users/marlon.savian/.gvm/pkgsets/go1.23.2/global/bin/aws-sso ${=_args} eval -p "$1")
    if [ "$AWS_SSO_PROFILE" != "$1" ]; then
        return 1
    fi
}

aws-sso-clear() {
    local _args=${AWS_SSO_HELPER_ARGS:- -L error}
    if [ -z "$AWS_SSO_PROFILE" ]; then
        echo "AWS_SSO_PROFILE is not set"
        return 1
    fi
    eval $(/Users/marlon.savian/.gvm/pkgsets/go1.23.2/global/bin/aws-sso ${=_args} eval -c)
}

compdef __aws_sso_profile_complete aws-sso-profile
complete -C /Users/marlon.savian/.gvm/pkgsets/go1.23.2/global/bin/aws-sso aws-sso

# END_AWS_SSO_CLI
