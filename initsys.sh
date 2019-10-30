#!/usr/bin/env bash

## script to initialise a working env remotely or locally
mkdir -p $HOME/usr/bin
export PATH="$HOME/usr/bin:$PATH"

#
if [[ $HOSTNAME == *'-aws-syd|-nec-hob'* ]]; then
    git clone https://github.com/lbesnard/dotfiles $HOME/dotfiles_lbesnard
    . $HOME/dotfiles_lbesnard/install
fi

# install linuxbrew
[[ ! -f $HOME/.linuxbrew/bin/brew ]] && sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"

export PATH="$HOME/.linuxbrew/bin:$PATH"
export MANPATH="$HOME/.linuxbrew/share/man:$MANPATH"
export INFOPATH="$HOME/.linuxbrew/share/info:$INFOPATH"

# install powerline fonts
[ ! -d $HOME/fonts/ ] && git clone https://github.com/powerline/fonts && source $HOME/fonts/install.sh

curl -fsSL -o $HOME/usr/bin/cheat https://github.com/cheat/cheat/releases/download/3.0.1/cheat-linux-amd64
chmod +x $HOME/usr/bin/cheat

# see https://github.com/Linuxbrew/homebrew-core/issues/955#issuecomment-250151297
export HOMEBREW_ARCH=core2
[ ! -f .linuxbrew/bin/gcc ] && brew install gcc
[ ! -e .linuxbrew/bin/zsh ] && brew install zsh
[ ! -f .linuxbrew/bin/autojump ] && brew install autojump
[ ! -e .linuxbrew/bin/tmux ] && brew install tmux
[ ! -e .linuxbrew/bin/git ] && brew install git
[ ! -e .linuxbrew/bin/curl ] && brew install curl
[ ! -e .linuxbrew/bin/vim ] && brew install vim
[ ! -e .linuxbrew/bin/hub ] && brew install hub
[ ! -e .linuxbrew/bin/fzf ] && brew install fzf
[ ! -e .linuxbrew/bin/ripgrep ] && brew install ripgrep
[ ! -e .linuxbrew/bin/fd ] && brew install fd
[ ! -e .linuxbrew/bin/the_silver_searcher ] && brew install the_silver_searcher
[ ! -e .linuxbrew/bin/mc ] && brew install midnight-commander
[ ! -e .linuxbrew/bin/fasd ] && brew install fasd
[ ! -e .linuxbrew/bin/pgcli ] && brew install brew tap-pin dbcli/tap && brew install pgcli
[ ! -e .linuxbrew/bin/lnav ] && brew install lnav
[ ! -e .linuxbrew/bin/p7zip ] && brew install p7zip
[ ! -e .linuxbrew/bin/ncdu ] && brew install ncdu
[ ! -e .linuxbrew/bin/fd ] && brew install fd
[ ! -e .linuxbrew/bin/cmake ] && brew install cmake


gem install colorls

# To install useful key bindings and fuzzy completion:
$(brew --prefix)/opt/fzf/install

[[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]] && . $(brew --prefix)/etc/profile.d/autojump.sh

if cd $HOME/dotfiles; then git pull; else git clone https://github.com/lbesnard/dotfiles.git; fi
. $HOME/dotfiles/install

#curl -fsSL -o .gitconfig https://raw.githubusercontent.com/lbesnard/dotfiles/master/gitconfig

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

vim +PlugInstall!

source $HOME/.bashrc # reload configuration

export PATH="$HOME/usr/bin:$PATH"
