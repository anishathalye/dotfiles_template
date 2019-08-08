# External plugins (initialized before)

# zsh-completions
fpath=(~/.zsh/plugins/zsh-completions/src $fpath)

# For zsh-history-substring-search plugin
source ~/.zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

