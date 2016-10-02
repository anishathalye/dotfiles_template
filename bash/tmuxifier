TMUXIFIER_BIN="$DOTFILES/tmuxifier/git/bin"
if [ -f "$TMUXIFIER_BIN/tmuxifier" ]; then
  export PATH="$TMUXIFIER_BIN:$PATH"
  export TMUXIFIER_LAYOUT_PATH="$DOTFILES/tmuxifier/layout"
  eval "$(tmuxifier init -)"
  alias windows="tmuxifier load-session kraig"
  alias kill-windows="tmux kill-window -t kraig"
fi
