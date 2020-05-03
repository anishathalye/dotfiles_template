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


## PrimaryKids functions
function tunnel_to_dev () {
    echo http://$(ipconfig getifaddr en0):9000
    ssh -nNT -L 0.0.0.0:9000:$(docker-machine ip):3000 $USER@localhost
}

p-ssh-to () {
    TARGET_HOST=${1}
    BASTION_HOST=${2}
    echo "Logging into $TARGET_HOST via bastion..."
    ssh -i ~/.ssh/id_rsa emiller@$TARGET_HOST -o "proxycommand ssh -W %h:%p -i ~/.ssh/id_rsa emiller@$BASTION_HOST"
}

function p-tunnel-to () {
    TARGET_HOST=${1}
    BASTION_HOST=${2}
    ssh -i key.pem -L 5432:localhost:5432 ec2-user@example.compute-1.amazonaws.com
}
