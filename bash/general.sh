# Set vi mode as default bash input type
set -o vi
export EDITOR="vim"

BASE16_SHELL="$DOTFILES/base16/base16-shell/"
[ -n "$PS1" ] && [ -s $BASE16_SHELL/profile_helper.sh ] && eval "$($BASE16_SHELL/profile_helper.sh)"
base16_atelier-forest
