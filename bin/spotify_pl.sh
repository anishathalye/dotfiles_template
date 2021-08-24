#!/usr/bin/env bash

main() {
    # download playlists
    IFS=$(echo -en "\n\b");
    local SCRIPT_DIR=$(dirname "$(realpath $0)" )
    local pl_vals=`cat $SCRIPT_DIR/.spotify_pl.list| fzf --no-preview | cut -d , -f1`
    local pl_path=/export/music/beet_library/playlists_navidrome

    for pl_val in $pl_vals; do
        redlist https://open.spotify.com/playlist/$pl_val

        ## replace values for navidrome in docker
        last_m3u=`ls -Art $pl_path`
        for f in $last_m3u;do
            last_m3u_path=$pl_path/"$f"
            sed -i "s#^/export/music/beet_library#/music#g" "$last_m3u_path";
        done
    done
}

main "$@"
