# Set emacs mode
set -o emacs

path_prepend "$HOME/.dotfiles/bin"

# For pyenv: https://github.com/pyenv/pyenv
export PYENV_ROOT="$HOME/.pyenv"
path_prepend "$PYENV_ROOT/bin"

# For Hub (http://hub.github.com)
eval "$(hub alias -s)"

# Setup docker machine env defaults
# Note: Only works if docker host `default` is running
eval $(docker-machine env default)
