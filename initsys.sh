#!/usr/bin/env bash

## script to install a functional working env on the $HOME directory
## using linuxbrew and ansible
## will install tools such as zsh, tmux, ranger, fzf ... and dotfiles

# install linuxbrew
# if user has sudo privileges, linuxbrew should be installed in /home/linuxbrew
# Otherwise the install script will automatically setup brew under $HOME/.linuxbrew
if ! [ -x "$(command -v brew)" ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# check where is linuxbrew installed
if [[ -d $HOME/.linuxbrew ]]; then
    export HOMEBREW_PREFIX=$HOME/.linuxbrew
elif [[ -d /home/linuxbrew ]]; then
    export HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew
fi

eval $($HOMEBREW_PREFIX/bin/brew shellenv)

export PATH="$HOMEBREW_PREFIX/bin:$PATH"
export MANPATH="$HOMEBREW_PREFIX/share/man:$MANPATH"
export INFOPATH="$HOMEBREW_PREFIX/share/info:$INFOPATH"

# see https://github.com/Linuxbrew/homebrew-core/issues/955#issuecomment-250151297
export HOMEBREW_ARCH=core2

# install or upgrade brew packages
function brew_install_or_upgrade {
    if brew ls --versions "$1" >/dev/null; then
        HOMEBREW_NO_AUTO_UPDATE=1; brew upgrade "$1"
    else
        HOMEBREW_NO_AUTO_UPDATE=1; brew install "$1"
    fi
}

# install or upgrade packages
brew_install_or_upgrade cmake
brew_install_or_upgrade gcc
brew_install_or_upgrade ruby
brew_install_or_upgrade ruby-install

brew_install_or_upgrade ansible

ansible-pull -U https://github.com/lbesnard/ansible_laptop.git remote.yml -i hosts -t brew
ansible-pull -U https://github.com/lbesnard/ansible_laptop.git remote.yml -i hosts -t dotfiles
ansible-pull -U https://github.com/lbesnard/ansible_laptop.git remote.yml -i hosts -t conda
ansible-pull -U https://github.com/lbesnard/ansible_laptop.git remote.yml -i hosts -t neovim
ansible-pull -U https://github.com/lbesnard/ansible_laptop.git remote.yml -i hosts -t cheat

# To install useful key bindings and fuzzy completion for fzf
$(brew --prefix)/opt/fzf/install
[[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]] && . $(brew --prefix)/etc/profile.d/autojump.sh
