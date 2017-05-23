#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sqlite3
import os
import sys

reload(sys)
sys.setdefaultencoding('utf8')
conn = sqlite3.connect('/home/lbesnard/musiclibrary.blb')
c = conn.cursor()

artpath = []
for row in c.execute('SELECT artpath from albums where artpath not NULL'):
    artpath.append(row[0])

for art in artpath:
    if not os.path.isfile(art):
        print art
        c.execute('UPDATE albums set artpath = NULL where artpath=?', (art,))


conn.commit()
conn.close()
