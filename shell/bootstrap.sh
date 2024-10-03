# Set emacs mode
set -o emacs

path_prepend "$HOME/bin"
path_prepend "$HOME/.dotfiles/bin"

# For rbenv
path_prepend "$HOME/.rbenv/bin"
if command -v rbenv 1>/dev/null 2>&1; then
    eval "$(rbenv init -)"
fi

# For nvm
# Setting NVM_DIR to the actual dir in dotfiles b/c setting it to the link
# was causing this prefix error, see solution here:
# https://stackoverflow.com/a/58559982/1190586
export NVM_DIR="$HOME/.dotfiles/nvm"
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

# For Alacritty (terminal) completions. This
# assumes that the zsh_functions directory
# exists in the home directory and has had the
# alacritty completion script copied to it. See
# also .install-alacritty.sh script where we
# do that preparation work.
fpath+=${ZDOTDIR:-~}/.zsh_functions
