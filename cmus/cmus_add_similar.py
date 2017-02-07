#!/usr/bin/env python
# -*- coding: utf-8 -*-

# written by Johannes Weißl <jargon@molb.org>, GPLv3

# ---------------------------------------------------------------------------
# configuration, can't use command line options because of cmus'
# status_display_program handling

# use new stdout saving feature, e.g.
# cmus-remote -C "save -l -"
#
# Required version of cmus: 2.4.x

# only consider tracks which are in the library when cmus starts
ONLY_TRACKS_IN_LIBRARY = True

# only use filtered library view
FILTERED_LIBRARY = True

# seconds after which remote saving occurs, 0: always
REMOTE_SAVING_TIMOUT = 30*60

# can be 'queue' or 'playlist'
ADD_TO = 'queue'

# if there are more tracks in queue or playlist then MAX_TRACKS, abort
# set to negative number to disable feature
MAX_TRACKS = -1

# percentage of similar artists to choose epsilon-greedy from
# (e.g. almost always choose an artist from the first third of the similar
# artists, just in 10% of all cases choose one from the other 2/3)
MOST_SIMILAR = 0.33
EPSILON = 0.1

# Remember the last n played tracks, and don't consider them for adding
REMEMBER_TRACKS = 10

# probability to not consider similar artists at all, but to choose
# completely randomly
JUMPOUT_EPSILON = 0.0

# enable debug output
DEBUG = True
# ---------------------------------------------------------------------------

import sys
import os
import os.path
import mmap
import struct
import random
import subprocess
import urllib
import urllib2
import re
import time
import stat

def die(msg):
    print >> sys.stderr, '%s: %s' % (sys.argv[0],msg)
    exit(1)

def warn(msg):
    print >> sys.stderr, '%s: %s' % (sys.argv[0],msg)

def debug(msg):
    if DEBUG:
        print >> sys.stderr, 'DEBUG: %s' % (msg,)
    
def list2dict(lst):
    return dict((lst[i],lst[i+1]) for i in xrange(0,len(lst),2))

def xml_entitiy_decode(text):
    entitydefs = {
        'quot': '"',
        'amp' : '&',
        'apos': "'",
        'lt'  : '<',
        'gt'  : '>'
    }
    def fixup(m):
        return entitydefs[m.group(1)]
    return re.sub('&('+'|'.join(entitydefs.keys())+');', fixup, text)

def xml_entitiy_encode(text):
    def fixup(m):
        return '%'+hex(ord(m.group(0)))[2:]
    return re.sub('["&\'<>]', fixup, text)

def detach():
    try:
        pid = os.fork()
        if pid != 0:
            os._exit(0)
    except:
        pass

def iter_ext_playlist(filename):
    try:
        f = open(filename, 'r')
    except IOError, e:
        errno, strerror = e
        warn('could not open %s: %s' % (self.cachepath, strerror))
        return
    try:
        buf = mmap.mmap(f.fileno(), 0, access=mmap.ACCESS_READ)
    except mmap.error, e:
        warn('could not mmap %s: %s' % (filename, str(e)))
        return
    try:
        info = {'tags': {}}
        while True:
            line = buf.readline()
            if not line:
                yield info
                break
            key, val = line.rstrip('\n').split(' ',1)
            if key == 'file':
                if info.get('file'):
                    yield info
                info = {'tags': {}, key: val}
            elif key == 'tag':
                key, val = val.split(' ',1)
                info['tags'][key] = val
            else:
                info[key] = val
    except Exception, e:
        warn('extended playlist "%s" is not valid: %s' % (filename,str(e)))
    finally:
        buf.close()
        f.close()


class AudioScrobbler(object):
    def __init__(self):
        self.root_url = 'http://ws.audioscrobbler.com/2.0/'
    def get_similar(self, artist):
        q_artist = urllib.quote_plus(xml_entitiy_encode(artist).encode('utf-8'), '')
        try:
            f = urllib2.urlopen(self.root_url+'artist/'+q_artist+'/similar.txt')
            d = f.read()
        except urllib2.HTTPError, e:
            raise Exception(str(e))
        tuples = [tuple(x.split(',',2)) for x in d.rstrip('\n').split('\n')]
        return [(a,b,xml_entitiy_decode(unicode(c, 'utf-8'))) for (a,b,c) in tuples]

class CMus(object):
    def __init__(self, confdir=None, timeout=30*60, remember=0):
        if not confdir:
            confdir = os.path.expandvars('${CMUS_HOME}')
            if not os.path.isabs(confdir):
                confdir = os.path.expanduser('~/.cmus')
        self.confdir = os.path.abspath(confdir)
        self.cachepath = self.confdir + '/cache'
        self.libpath = self.confdir + '/lib.pl'
        self.extpath = self.confdir + '/lib.extpl'
        self.playedpath = self.confdir + '/added_tracks.pl'
        self.remotecmd = ['cmus-remote']
        self.libfiles = set()
        self.timeout = timeout
        self.artists = {}
        self.cache = {}
        self.remember = remember
        self.added_tracks = []
        if self.remember > 0:
            self.read_added_tracks()
    def finalize(self):
        if self.remember > 0:
            self.write_added_tracks()
    def is_running(self):
        try:
            subprocess.check_call(self.remotecmd + ['-C'])
        except OSError:
            return False
        except subprocess.CalledProcessError:
            return False
        return True
    def addfile(self, filename, target='queue'):
        opt = '-P' if target == 'playlist' else '-q'
        subprocess.Popen(self.remotecmd + [opt, filename])
        if self.remember > 0:
            self.added_tracks.append(filename)
    def read_editable(self, view):
        opt = '-p' if view == 'playlist' else '-q'
        files = subprocess.Popen(self.remotecmd + ['-C', 'save '+opt+' -'], stdout=subprocess.PIPE).communicate()[0].rstrip('\n').split('\n')
        return files
    def read_dumped_lib(self, filtered=True):
        do_dumping = False
        try:
            mtime1 = os.stat(self.extpath)[stat.ST_MTIME]
            mtime2 = os.stat(self.libpath)[stat.ST_MTIME]
            if mtime2 > mtime1:
                do_dumping = True
            elif mtime1 + self.timeout < time.time():
                do_dumping = True
        except OSError:
            do_dumping = True
        if do_dumping:
            opt = '-L' if filtered else '-l'
            try:
                f = open(self.extpath, 'w')
                subprocess.Popen(self.remotecmd + ['-C', 'save -e '+opt+' -'], stdout=f).communicate()
                f.close()
            except IOError, e:
                errno, strerror = e
                warn('could not open %s for writing: %s' % (self.extpath, strerror))
        for info in iter_ext_playlist(self.extpath):
            filename = info.get('file')
            artist = info['tags'].get('artist')
            title = info['tags'].get('title')
            if filename and artist and title:
                artist = unicode(artist, 'utf-8')
                title = unicode(title, 'utf-8')
                if artist not in self.artists:
                    self.artists[artist] = {}
                self.artists[artist][title] = filename
    def read_added_tracks(self):
        try:
            f = open(self.playedpath)
            self.added_tracks = [line.rstrip('\n') for line in f][-self.remember:]
            f.close()
        except:
            pass
    def write_added_tracks(self):
        try:
            f = open(self.playedpath, 'w')
            f.write('\n'.join(self.added_tracks[-self.remember:])+'\n')
            f.close()
        except IOError, e:
            errno, strerror = e
            warn('could not open %s for writing: %s' % (self.playedpath, strerror))

def main(argv=None):
    if not argv:
        argv = sys.argv

    if len(argv) < 2 or len(argv) % 2 != 1:
        die('Usage: %s key value [key value]...\n\none key should be \"artist\"')
    
    cur_track = list2dict(argv[1:])
    if 'artist' not in cur_track:
        die('no artist given')
    
    cmus = CMus(timeout=REMOTE_SAVING_TIMOUT, remember=REMEMBER_TRACKS)
    
    if not cmus.is_running():
        die('cmus not running or cmus-remote not working')

    if not DEBUG:
        detach()

    if MAX_TRACKS >= 0:
        count = len(cmus.read_editable(ADD_TO))
        if count > MAX_TRACKS:
            debug('more than %d tracks (%d) in view %s, aborting' % (MAX_TRACKS, count, ADD_TO))
            return 0
    cmus.read_dumped_lib(filtered=FILTERED_LIBRARY)

    if not cmus.artists:
        die('no artists in library / cache')

    audioscrobbler = AudioScrobbler()
    
    artist_name = unicode(cur_track['artist'], 'utf-8')
    try:
        all_similar_artists = audioscrobbler.get_similar(artist_name)
    except Exception, e:
        die('cannot fetch similar artists to "'+artist_name+'": '+str(e))

    debug('searching for similar artists to "%s"' % (artist_name,))

    similar_artists = [a[2] for a in all_similar_artists if a[2] in cmus.artists]
    debug('you have %d from %d similar artists' % (len(similar_artists),len(all_similar_artists)))
    if random.random() < JUMPOUT_EPSILON or not similar_artists:
        if not similar_artists:
            warn('no similar artist found, choosing completely randomly')
        else:
            debug('hah! %s%% probability, doing a jump out of similar artists' % (str(100*JUMPOUT_EPSILON),))
        similar_artists = cmus.artists.keys()
        random.shuffle(similar_artists)
    else:
        n_most_similar = int(len(similar_artists) * MOST_SIMILAR)
        most_similar_artists = similar_artists[:n_most_similar]
        lesser_similar_artists = similar_artists[n_most_similar:]
        random.shuffle(most_similar_artists)
        random.shuffle(lesser_similar_artists)
        if random.random() < EPSILON:
            similar_artists = lesser_similar_artists + most_similar_artists
            debug('choosing from the %s%% (= %d) lesser similar artists' % (str(100*(1-MOST_SIMILAR)),len(lesser_similar_artists)))
        else:
            similar_artists = most_similar_artists + lesser_similar_artists
            debug('choosing from the %s%% (= %d) most similar artists' % (str(100*MOST_SIMILAR),len(most_similar_artists)))
        # append all other artists
        additional_artists = [a for a in cmus.artists.keys() if a not in similar_artists]
        random.shuffle(additional_artists)
        similar_artists += additional_artists

    next_track = None
    for similar_artist in similar_artists:
        if cmus.artists[similar_artist]:
            files = cmus.artists[similar_artist].values()
            random.shuffle(files)
            for f in files:
                if f in cmus.added_tracks:
                    debug('track "%s" is among the last %d added tracks, continuing...' % (f,len(cmus.added_tracks)))
                    continue
                if os.path.exists(f):
                    next_track = f
                    break
                else:
                    debug('path "%s" does not exist, continuing...' % (f,))
            if next_track:
                break

    if next_track:
        cmus.addfile(next_track,target=ADD_TO)
        debug("add file \"%s\" to %s\n" % (next_track,ADD_TO))
    else:
        die('no existing track found to add')

    cmus.finalize()

    return 0

if __name__ == '__main__':
    sys.exit(main())
