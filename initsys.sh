#!/usr/bin/env bash

## script to initialise a working env remotely or locally
export PATH="$HOME/usr/bin:$PATH"

# install linuxbrew
[[ ! -f $HOME/.linuxbrew/bin/brew ]] && ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"

export PATH="$HOME/.linuxbrew/bin:$PATH"
export MANPATH="$HOME/.linuxbrew/share/man:$MANPATH"
export INFOPATH="$HOME/.linuxbrew/share/info:$INFOPATH"

# install powerline fonts
[ ! -d $HOME/fonts/ ] && git clone git@github.com:powerline/fonts.git && source $HOME/fonts/install.sh

# see https://github.com/Linuxbrew/homebrew-core/issues/955#issuecomment-250151297
export HOMEBREW_ARCH=core2
[ ! -f .linuxbrew/bin/gcc ] && brew install gcc
[ ! -e .linuxbrew/bin/zsh ] && brew install zsh
[ ! -f .linuxbrew/bin/autojump ] && brew install autojump
[ ! -e .linuxbrew/bin/tmux ] && brew install tmux
[ ! -e .linuxbrew/bin/git ] && brew install git
[ ! -e .linuxbrew/bin/curl ] && brew install curl
[ ! -e .linuxbrew/bin/vim ] && brew install vim

[[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]] && . $(brew --prefix)/etc/profile.d/autojump.sh

curl -fsSL -o .zshrc https://raw.githubusercontent.com/lbesnard/dotfiles/master/zshrc.zplug.ssh
curl -fsSL -o .tmux.conf https://raw.githubusercontent.com/lbesnard/dotfiles/master/tmux.conf.ssh
curl -fsSL -o .vimrc https://raw.githubusercontent.com/lbesnard/dotfiles/master/vim/vimrc
curl -fsSL -o .gitconfig https://raw.githubusercontent.com/lbesnard/dotfiles/master/gitconfig

export SHELL=$HOME/.linuxbrew/bin/zsh

#add line to bashrc only if not exist
add_line_bashrc() {
    local line="$1"; shift
    grep -q "^${line}$" $HOME/.bashrc ||  echo $line >> $HOME/.bashrc
}

add_line_bashrc 'export PATH="$HOME/.linuxbrew/bin:$PATH"'
add_line_bashrc 'export MANPATH="$HOME/.linuxbrew/share/man:$MANPATH"'
add_line_bashrc 'export INFOPATH="$HOME/.linuxbrew/share/info:$INFOPATH"'
add_line_bashrc 'export SHELL="$HOME/.linuxbrew/bin/zsh"'
add_line_bashrc '$HOME/.linuxbrew/bin/zsh'

vim +VundleClean +PluginInstall +qall

source $HOME/.bashrc # reload configuration
