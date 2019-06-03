path_remove() {
    PATH=$(echo -n $PATH | awk -v RS=: -v ORS=: '$0 != "'$1'"' |sed 's/:$//')
}

path_append() {
    path_remove "$1"
    PATH="${PATH:+"$PATH:"}$1"
}

path_prepend() {
    path_remove "$1"
    PATH="$1${PATH:+":$PATH"}"
}


function tunnel_to_dev () {
    echo http://$(ipconfig getifaddr en0):9000
    ssh -nNT -L 0.0.0.0:9000:$(docker-machine ip):3000 $USER@localhost
}
