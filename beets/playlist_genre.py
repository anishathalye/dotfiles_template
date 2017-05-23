#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sqlite3

conn = sqlite3.connect('/home/lbesnard/musiclibrary.blb.bckp')
c = conn.cursor()
genre_ls = []
for row in c.execute('SELECT distinct(genre) from albums where genre not NULL'):
    genre_ls.append(row[0])

genre_ls.sort()

for genre in genre_ls:
    mp3_path = []
    playlist_path = ('/home/lbesnard/playlists/%s.m3u' % genre.replace('/', '_'))

    c.execute('SELECT path from items where genre=?', (genre,))

    rows = c.fetchall()
    for row in rows:
        mp3_path.append(row[0][:])

    with open(playlist_path, 'w') as f:
        for item in mp3_path:
            f.write("%s\n" % item)

conn.close()
