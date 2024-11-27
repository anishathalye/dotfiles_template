FZF_DOCKER_PS_FORMAT="table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Ports}}"
FZF_DOCKER_PS_START_FORMAT="table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}"

_fzf_complete_docker() {
  # Get all Docker commands
  #
  # Cut below "Management Commands:", then exclude "Management Commands:",
  # "Commands:" and the last line of the help. Then keep the first column and
  # delete empty lines
  DOCKER_COMMANDS=$(docker --help 2>&1 >/dev/null |
    sed -n -e '/Management Commands:/,$p' |
    grep -v "Management Commands:" |
    grep -v "Commands:" |
    grep -v 'COMMAND --help' |
    grep .
  )

  ARGS="$@"
  if [[ $ARGS == 'docker ' ]]; then
    _fzf_complete "--reverse -n 1 --height=80%" "$@" < <(
      echo $DOCKER_COMMANDS
    )
  elif [[ $ARGS == 'docker tag'* || $ARGS == 'docker -f'* || $ARGS == 'docker run'* || $ARGS == 'docker push'* ]]; then
    _fzf_complete "--multi --header-lines=1" "$@" < <(
      docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.ID}}\t{{.CreatedSince}}"
    )
  elif [[ $ARGS == 'docker rmi'* ]]; then
    _fzf_complete "--multi --header-lines=1" "$@" < <(
      docker images --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}\t{{.Size}}"
    )
  elif [[ $ARGS == 'docker stop'* || $ARGS == 'docker exec'* || $ARGS == 'docker kill'* || $ARGS == 'docker restart'* ]]; then
    _fzf_complete "--multi --header-lines=1 " "$@" < <(
      docker ps --format "${FZF_DOCKER_PS_FORMAT}"
    )  
  elif [[ $ARGS == 'docker logs'* ]]; then
    _fzf_complete "--multi --header-lines=1 --header 'Enter CTRL-O to open log in editor | CTRL-/ to change height\n\n' --bind 'ctrl-/:change-preview-window(80%,border-bottom|)' --bind \"ctrl-o:execute:docker logs {1} | sed 's/\x1b\[[0-9;]*m//g' | cat | ${EDITOR:-vim} -\" --preview-window up:follow --preview 'docker logs --follow --tail=100 {1}' " "$@" < <(
      docker ps -a --format "${FZF_DOCKER_PS_FORMAT}"
    )
  elif [[ $ARGS == 'docker rm'* ]]; then
    _fzf_complete "--multi --header-lines=1 " "$@" < <(
      docker ps -a --format "${FZF_DOCKER_PS_FORMAT}"
  )
  elif [[ $ARGS == 'docker start'* ]]; then
     _fzf_complete "--multi --header-lines=1 " "$@" < <(
      docker ps -a --format "${FZF_DOCKER_PS_START_FORMAT}"
    )
  fi
}

_fzf_complete_docker_post() {
  # Post-process the fzf output to keep only the command name and not the explanation with it
  awk '{print $1}'
}

[ -n "$BASH" ] && complete -F _fzf_complete_docker -o default -o bashdefault docker
