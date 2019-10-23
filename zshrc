if [ -d "/usr/share/powerline/bindings/bash" ]; then
    source /usr/share/powerline/bindings/bash/powerline.sh
fi

# load different zshrc depending on hostname
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
    source $HOME/.zshrc.zplug
    ln -sf ~/.tmux.conf.local ~/.tmux.conf
fi

MCR_ROOT="/opt/MATLAB/MATLAB_Runtime/v95"
MCR_APPS="$MCR_ROOT/bin:$MCR_ROOT/glnxa64"
export PATH="$PATH:$MCR_APPS"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/lbesnard/.sdkman"
[[ -s "/home/lbesnard/.sdkman/bin/sdkman-init.sh" ]] && source "/home/lbesnard/.sdkman/bin/sdkman-init.sh"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/lbesnard/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/lbesnard/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/lbesnard/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/lbesnard/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
export VIRTUALENVWRAPPER_PYTHON=/home/lbesnard/anaconda3/bin/python
# <<< conda initialize <<<


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
