function cheat_fzf(){
    eval `cheat -l | tail -n +2 | fzf --reverse --preview '(cheat $(echo {} | cut -d " " -f1 ))' | awk -v vars="$*" '{ print "cheat " $1 " -t " $3, vars }'`
}
