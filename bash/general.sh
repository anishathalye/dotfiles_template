# Set vi mode as default bash input type
set -o vi
export EDITOR="vim"

BASE16_SHELL="$DOTFILES/base16/base16-shell/"
[ -n "$PS1" ] && [ -s $BASE16_SHELL/profile_helper.sh ] && eval "$($BASE16_SHELL/profile_helper.sh)"
base16_atelier-forest

# Check the win size since tmux will change the size often
shopt -s checkwinsize

# Use coreutils utils for OSX
if [[ $(uname -s) == "Darwin" ]]; then
  PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
  [ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
fi
