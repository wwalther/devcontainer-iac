# =============================================================================
# ~/.bash_profile
# Loaded by: ~/.bashrc (which sources this for all interactive shells)
# =============================================================================

# Guard against double-sourcing
[[ -n "${__BASH_PROFILE_LOADED:-}" ]] && return
readonly __BASH_PROFILE_LOADED=1

# =============================================================================
# Bash completion
# =============================================================================
if [[ -f /usr/share/bash-completion/bash_completion ]]; then
  source /usr/share/bash-completion/bash_completion
fi

# =============================================================================
# History
# =============================================================================
HISTSIZE=100000
HISTFILESIZE=200000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend

# Share history across sessions
PROMPT_COMMAND="${PROMPT_COMMAND:+${PROMPT_COMMAND};}history -a; history -c; history -r"

# =============================================================================
# Editor
# =============================================================================
export EDITOR=vi
export VISUAL=vi

# =============================================================================
# PS1 helpers
# =============================================================================

# __ps1_git: outputs a colored git branch segment for PS1.
# Clean = green, dirty (uncommitted changes) = red with trailing *.
# Uses \001/\002 (SOH/STX) instead of \[/\] so the markers work in command substitution output.
__ps1_git() {
  local branch dirty
  if branch="$(git symbolic-ref --short HEAD 2>/dev/null)"; then
    :
  elif branch="$(git rev-parse --short HEAD 2>/dev/null)"; then
    branch="(${branch})"
  else
    return
  fi
  if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
    dirty="*"
    printf $' \001\e[1;31m\002(%s%s)\001\e[0m\002' "${branch}" "${dirty}"
  else
    printf $' \001\e[1;32m\002(%s)\001\e[0m\002' "${branch}"
  fi
}

# __git_branch: returns current branch name without color, for scripting use.
__git_branch() {
  local branch
  if branch="$(git symbolic-ref --short HEAD 2>/dev/null)"; then
    printf '%s' "${branch}"
  elif branch="$(git rev-parse --short HEAD 2>/dev/null)"; then
    printf '(%s)' "${branch}"
  fi
}

# PS1: bold-cyan user @ bold-blue host : bold-yellow dir [git branch] bold $
PS1='\[\e[1;36m\]\u\[\e[0m\]@\[\e[1;34m\]\h\[\e[0m\]:\[\e[1;33m\]\w\[\e[0m\]'
PS1+='$(__ps1_git)'
PS1+='\[\e[1m\]\$\[\e[0m\] '

# =============================================================================
# Aliases — General
# =============================================================================
alias ll='ls -lh --color=auto'
alias la='ls -lah --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

# =============================================================================
# Aliases — Git
# =============================================================================
alias gs='git status'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias gp='git push'
alias gc='git commit'

# =============================================================================
# Aliases — OpenTofu
# =============================================================================
alias tf='tofu'
alias tfi='tofu init'
alias tfp='tofu plan'
alias tfa='tofu apply'
alias tfd='tofu destroy'
alias tfv='tofu validate'
alias tff='tofu fmt'

# =============================================================================
# Aliases — Terragrunt
# =============================================================================
alias tg='terragrunt'
alias tgi='terragrunt init'
alias tgp='terragrunt plan'
alias tga='terragrunt apply'
alias tgd='terragrunt destroy'

# =============================================================================
# Aliases — AWS
# =============================================================================
alias aws-whoami='aws sts get-caller-identity'
alias aws-profiles='aws configure list-profiles'
alias aws-region='aws configure get region'

# =============================================================================
# Aliases — Azure
# =============================================================================
alias az-whoami='az account show'
alias az-subs='az account list --output table'
alias az-sub='az account show --query name --output tsv'

# =============================================================================
# Functions
# =============================================================================

# mkcd: create a directory (with parents) and cd into it
mkcd() {
  if [[ $# -ne 1 ]]; then
    printf 'Usage: mkcd <directory>\n' >&2
    return 1
  fi
  mkdir -p -- "$1" && cd -- "$1" || return 1
}

# tofu_workspace: print the current OpenTofu workspace name
tofu_workspace() {
  tofu workspace show 2>/dev/null || printf '(no workspace)\n'
}
