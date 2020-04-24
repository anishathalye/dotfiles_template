# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# Make sure to run vte.sh
if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
        source /etc/profile.d/vte.sh
fi

# Set up path for our dotfiles repo
THIS_FILE=${BASH_SOURCE[0]}
THIS_REAL=$(realpath -P $THIS_FILE)
DOTBASH=$(dirname $THIS_REAL)
DOTFILES=$(realpath "$DOTBASH/../")

source "$DOTBASH/general.sh"
source "$DOTBASH/alias.sh"
source "$DOTBASH/tmuxifier.sh"
