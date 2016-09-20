# Set up the prompt
[ -f $HOME/.env ] && source $HOME/.env
[ -f $HOME/.alias ] && source $HOME/.alias
source  /etc/profile.d/* # especially useful for remote connection

antigen_zsh=$HOME/.antigen/antigen.zsh
if [ ! -f $antigen_zsh ]; then
    echo "Installing antigen..."
    echo ""
    mkdir -p ~/.antigen;
    curl https://cdn.rawgit.com/zsh-users/antigen/v1.1.2/bin/antigen.zsh > $HOME/.antigen/antigen.zsh;
fi
source $antigen_zsh


antigen use oh-my-zsh
antigen bundle git
antigen bundle heroku
antigen bundle pip
antigen bundle lein
antigen bundle command-not-found
antigen bundle ssh-agent

# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-bash
antigen bundle common-aliases
antigen bundle zsh-users/zsh-history-substring-search ./zsh-history-substring-search.zsh
antigen bundle compleat
antigen bundle debian
antigen bundle autojump
antigen bundle autopep8
antigen bundle git-extras
antigen bundle gitfast
antigen bundle sublime
antigen bundle tmux
antigen bundle sudo
antigen bundle web-search
antigen bundle rutchkiwi/copyzshell
antigen bundle horosgrisa/zsh-dropbox
antigen bundle zsh-users/zsh-autosuggestions


# Load the theme.
antigen theme agnoster
#antigen theme https://github.com/caiogondim/bullet-train-oh-my-zsh-theme bullet-train


# completion 
_cmpl_cheat() {
reply=($(cheat -l | cut -d' ' -f1))
}
compctl -K _cmpl_cheat cheat

# Tell antigen that you're done.
antigen apply
if command -v tmux>/dev/null; then
  [[ ! $TERM =~ screen ]] && [ -z $TMUX ] && exec tmux -2 attach
fi
