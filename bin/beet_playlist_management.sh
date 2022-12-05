#!/usr/bin/env bash
# script automatically called by beet after import to clean playlists to be used
# by different webapps

IFS=$(echo -en "\n\b");

# renaming the "relative_to" part of the playlist created in smartplaylist beet
# pluging so this can be used in the airsonic docker container automatically
for f in `find /media/lbesnard/bfunk_10tb_3/music/playlists -type f`; do
    sed -i "s#../beet_library#/music#g" "$f";
done

# for airsonic-advanced
cp /media/lbesnard/bfunk_10tb_3/music/playlists/* /media/lbesnard/bfunk_10tb_3/music/playlists_airsonic_advanced/;
for f in `find /media/lbesnard/bfunk_10tb_3/music/playlists_airsonic_advanced -type f`; do
    sed -i "s#^/music#/var/music#g" "$f";
done

# for navidrome
# disabling this for now. I prefer to use the spotify pl. commenting
#cp /media/lbesnard/bfunk_10tb_3/music/playlists/* /media/lbesnard/bfunk_10tb_3/music/beet_library/playlists_navidrome/;
#for f in `find /media/lbesnard/bfunk_10tb_3/music/beet_library/playlists_navidrome -type f`; do
    #sed -i "s#^/music#/music#g" "$f";
#done
