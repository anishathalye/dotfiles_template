# Set emacs mode
set -o emacs

path_prepend "$HOME/.dotfiles/bin"

# For rbenv
path_prepend "$HOME/.rbenv/bin"
if command -v rbenv 1>/dev/null 2>&1; then
    eval "$(rbenv init -)"
fi

# For nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # this loads nvm

# For pyenv: https://github.com/pyenv/pyenv
export PYENV_ROOT="$HOME/.pyenv"
path_prepend "$PYENV_ROOT/bin"
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

# For direnv
if command -v direnv 1>/dev/null 2>&1; then
    eval "$(direnv hook zsh)"
fi

# For miniconda
path_prepend "$HOME/miniconda/bin"
path_append "$HOME/miniconda"

# For Hub (http://hub.github.com)
eval "$(hub alias -s)"

# Setup docker machine env defaults
# Note: Only works if docker host `default` is running
eval $(docker-machine env default)
