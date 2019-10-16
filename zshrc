# load different zshrc depending on hostname
HOSTNAME=$(hostname)
if [[ $HOSTNAME == *"aws"* ]]; then
    source $HOME/.zshrc.zplug.ssh
elif [[ $HOSTNAME == *"nec"* ]]; then
    source $HOME/.zshrc.zplug.ssh
elif [[ $HOSTNAME == *"brownfunk"* ]]; then
    source $HOME/.zshrc.zplug.ssh
else
    source $HOME/.zshrc.zplug
fi

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

