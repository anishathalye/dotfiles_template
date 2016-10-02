# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# Set up path for our dotfiles repo
THIS_FILE=${BASH_SOURCE[0]}
THIS_REAL=$(realpath -P $THIS_FILE)
DOTBASH=$(dirname $THIS_REAL)
DOTFILES=$(realpath "$DOTBASH/../")

source "$DOTBASH/general.sh"
source "$DOTBASH/alias.sh"
source "$DOTBASH/tmuxifier.sh"
