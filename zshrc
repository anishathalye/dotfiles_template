if [ -d "/usr/share/powerline/bindings/bash" ]; then
    source /usr/share/powerline/bindings/bash/powerline.sh
fi


source $HOME/.zshrc.zplug.common

# load different zshrc/tmux config file depending on HOSTNAME
HOSTNAME=$(hostname)
if [[ $HOSTNAME == *"aws"* ]]; then
    source $HOME/.zshrc.zplug.ssh
    ln -sf ~/.tmux.conf.ssh ~/.tmux.conf
elif [[ $HOSTNAME == *"nec"* ]]; then
    source $HOME/.zshrc.zplug.ssh
    ln -sf ~/.tmux.conf.ssh ~/.tmux.conf
elif [[ $HOSTNAME == *"brownfunk"* ]]; then
    source $HOME/.zshrc.zplug.bfunk
    ln -sf ~/.tmux.conf.ssh ~/.tmux.conf
else
    source $HOME/.zshrc.zplug.local
    ln -sf ~/.tmux.conf.local ~/.tmux.conf
fi



#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('$HOME/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
export VIRTUALENVWRAPPER_PYTHON=$HOME/anaconda3/bin/python
# <<< conda initialize <<<

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
