path_prepend "$HOME/.dotfiles/bin"

# For Hub (http://hub.github.com)
eval "#(hub alias -s)"

# Setup docker machine env defaults
# Note: Only works if docker host `default` is running
eval $(docker-machine env default)
