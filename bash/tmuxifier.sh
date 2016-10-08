TMUXIFIER_BIN="$DOTFILES/tmuxifier/git/bin"
TMUX_VERSION=$(tmux -V 2>/dev/null | cut -f2 -d" ")

create_windows() {
  export PROJ="$1"
  tmuxifier load-session kraig
}

if [[ $? == 0 && "$TMUX_VERSION" > "1.6" && -f "$TMUXIFIER_BIN/tmuxifier" ]]; then
  export PATH="$TMUXIFIER_BIN:$PATH"
  export TMUXIFIER_LAYOUT_PATH="$DOTFILES/tmuxifier/layout"
  eval "$(tmuxifier init -)"
  # Usage `windows ~/root`
  # Uses given dir for the window root
  alias windows=create_windows
  alias kill-windows="tmux kill-window -t kraig"
else
  alias windows="echo 'tmux must be installed and >version 1.6'"
  alias kill-windows="echo 'tmux must be installed and >version 1.6'"
fi
