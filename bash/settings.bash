HISTSIZE=1048576
HISTFILE="$HOME/.bash_history"
SAVEHIST=$HISTSIZE
shopt -s histappend # append to history file

# Set emacs mode for bash key bindings
set -o emacs

export EDITOR=vim
