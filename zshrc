autoload -U compinit
autoload colors
compinit
colors

# Options
setopt nonomatch # allow us to do bracket-based commands without ugliness
setopt EXTENDED_HISTORY # add timestamps to history
setopt LOCAL_OPTIONS # allow functions to have local options
setopt LOCAL_TRAPS # allow functions to have local traps
setopt PROMPT_SUBST
setopt COMPLETE_IN_WORD
setopt IGNORE_EOF
setopt AUTO_CD
setopt HIST_IGNORE_DUPS
setopt APPEND_HISTORY # adds history
setopt INC_APPEND_HISTORY SHARE_HISTORY  # adds history incrementally and share it across sessions
setopt HIST_IGNORE_ALL_DUPS  # do not record dupes in history
setopt HIST_REDUCE_BLANKS

#Completion
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # case insensitive completion
zstyle ':completion:*:default' menu 'select=0' # menu-style

# Prompt
git_prompt_info() {
  ref=$($(which git) symbolic-ref HEAD 2> /dev/null) || return
  mods=$(vcprompt -f %m) || return
  echo "%{$reset_color%}(%{$fg[red]%}${ref#refs/heads/}%{$fg[yellow]%}${mods}%{$reset_color%})"
}
export PROMPT='%m%{$reset_color%}:%{$fg[cyan]%}%c$(git_prompt_info) %{$reset_color%}%% '

# Bindings
bindkey -M viins '^R' history-incremental-pattern-search-backward
bindkey -M viins '^F' history-incremental-pattern-search-forward
bindkey -M viins '^P' up-history
bindkey -M viins '^N' down-history

typeset -U path cdpath fpath

# PGP for signing git commits
export PATH="/usr/local/opt/gpg-agent/bin:$PATH"
if [ -f ~/.gnupg/.gpg-agent-info ] && [ -n "$(pgrep gpg-agent)" ]; then
    source ~/.gnupg/.gpg-agent-info
    export GPG_AGENT_INFO
else
    eval $(gpg-agent --daemon --write-env-file ~/.gnupg/.gpg-agent-info)
fi

### aliases
alias ls="ls -lh"

# git
alias gca="git commit --amend --no-edit"
alias gd='git diff'
alias gds='git diff --staged'
alias gs='git status'

# ruby
alias be="bundle exec"

# tmux
alias tmux="TERM=screen-256color-bce tmux"
