TMUXIFIER_BIN="$DOTFILES/tmuxifier/git/bin"
TMUX_VERSION=$(tmux -V 2>/dev/null | cut -f2 -d" ")

get_proj_name() {
  if [[ -z "$1" ]]; then
    P="$PWD"
  else
    P="$1"
  fi
  export PROJ="$P"
  export PROJ_NAME=$(realpath "$PROJ" | xargs basename)
}

create_windows() {
  get_proj_name $1
  tmuxifier load-session kraig
}

new_windows() {
  get_proj_name $1
  if [[ -d $PROJ ]]; then
    tmuxifier load-window code
  else
    echo "Arg must be a directory"
  fi
}

if [[ $? == 0 && "$TMUX_VERSION" > "1.6" && -f "$TMUXIFIER_BIN/tmuxifier" ]]; then
  export PATH="$TMUXIFIER_BIN:$PATH"
  export TMUXIFIER_LAYOUT_PATH="$DOTFILES/tmuxifier/layout"
  eval "$(tmuxifier init -)"
  # Usage `windows ~/root`
  # Uses given dir for the window root
  alias windows=create_windows
  alias kill-windows="tmux kill-session -t kraig"
  alias new-window=new_windows
else
  alias windows="echo 'tmux must be installed and >version 1.6'"
  alias kill-windows="echo 'tmux must be installed and >version 1.6'"
  alias new-window="echo 'tmux must be installed and >version 1.6'"
fi
