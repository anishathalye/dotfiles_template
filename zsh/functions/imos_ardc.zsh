function _ardc_log() {
    local ardc_log_dir=$WIP_DIR/ARDC_API_NRT
    # fname is not local to be re-used by other sub-functions

    if command -v fzf > /dev/null; then
        fname=$(find $ardc_log_dir -type f -name "process.log" | \
        fzf --preview "( [[ -f {} ]] && (tail -50 {} || cat {}))")
    else
        printf "Please select log file:\n"
        select fname in `find $ardc_log_dir -type f -name process.log`;
        do
          echo you picked $fname \($REPLY\)
          break;
        done
    fi
}
#export -f _ardc_log

function ardc_log_recent() {
    _ardc_log
    local hrago=$(date --date="1 hours ago" "+%Y-%m-%d %H")

    sed -n "/^$hrago/,\$p" $fname | perl -pe 's/^.*FATAL.*$/\e[1;37;41m$&\e[0m/g; s/^.*ERROR.*$/\e[1;31;40m$&\e[0m/g; s/^.*WARN.*$/\e[0;33;40m$&\e[0m/g; s/^.*INFO.*$/\e[0;36;40m$&\e[0m/g; s/^.*DEBUG.*$/\e[0;37;40m$&\e[0m/g'
    }
#export -f ardc_log_recent

function ardc_log_recent_errors() {
    _ardc_log
    local hrago=$(date --date="1 hours ago" "+%Y-%m-%d %H")

    sed -n "/^$hrago/,\$p" $fname | grep ERROR | perl -pe 's/^.*FATAL.*$/\e[1;37;41m$&\e[0m/g; s/^.*ERROR.*$/\e[1;31;40m$&\e[0m/g; s/^.*WARN.*$/\e[0;33;40m$&\e[0m/g; s/^.*INFO.*$/\e[0;36;40m$&\e[0m/g; s/^.*DEBUG.*$/\e[0;37;40m$&\e[0m/g '
    }
#export -f ardc_log_recent_errors


