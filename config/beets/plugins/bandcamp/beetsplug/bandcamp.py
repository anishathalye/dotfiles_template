# Copyright 2015, Ariel George.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

"""Adds bandcamp album search support to the autotagger. Requires the
BeautifulSoup library.
"""

from __future__ import (division, absolute_import, print_function,
                        unicode_literals)

import beets.ui
from beets.autotag.hooks import AlbumInfo, TrackInfo, Distance
from beets import plugins
from beetsplug import fetchart
import beets
import requests
from bs4 import BeautifulSoup
import isodate


USER_AGENT = u'beets/{0} +http://beets.radbox.org/'.format(beets.__version__)
BANDCAMP_SEARCH = u'http://bandcamp.com/search?q={query}&page={page}'
BANDCAMP_ALBUM = u'album'
BANDCAMP_ARTIST = u'band'
BANDCAMP_TRACK = u'track'


class BandcampPlugin(plugins.BeetsPlugin):

    def __init__(self):
        super(BandcampPlugin, self).__init__()
        self.config.add({
            'source_weight': 0.5,
            'min_candidates': 5,
            'lyrics': False,
            'art': False
        })
        self.import_stages = [self.imported]
        self.register_listener('pluginload', self.loaded)

    def loaded(self):
        # Add our own artsource to the fetchart plugin.
        # FIXME: This is ugly, but i didn't find another way to extend fetchart
        # without declaring a new plugin.
        if self.config['art']:
            for plugin in plugins.find_plugins():
                if isinstance(plugin, fetchart.FetchArtPlugin):
                    plugin.sources = [BandcampAlbumArt(plugin._log, self.config)] + plugin.sources
                    fetchart.ART_SOURCES[u'bandcamp'] = BandcampAlbumArt
                    break

    def album_distance(self, items, album_info, mapping):
        """Returns the album distance.
        """
        dist = Distance()
        if hasattr(album_info, 'data_source') and album_info.data_source == 'bandcamp':
            dist.add('source', self.config['source_weight'].as_number())
        return dist

    def candidates(self, items, artist, album, va_likely):
        """Returns a list of AlbumInfo objects for bandcamp search results
        matching an album and artist (if not various).
        """
        return self.get_albums(album)

    def album_for_id(self, album_id):
        """Fetches an album by its bandcamp ID and returns an AlbumInfo object
        or None if the album is not found.
        """
        # We use album url as id, so we just need to fetch and parse the
        # album page.
        url = album_id
        return self.get_album_info(url)

    def item_candidates(self, item, artist, album):
        """Returns a list of TrackInfo objects from a bandcamp search matching
        a singleton.
        """
        if item.title:
            return self.get_tracks(item.title)
        if item.album:
            return self.get_tracks(item.album)
        if item.artist:
            return self.get_tracks(item.artist)
        return []

    def track_for_id(self, track_id):
        """Fetches a track by its bandcamp ID and returns a TrackInfo object
        or None if the track is not found.
        """
        url = track_id
        return self.get_track_info(url)

    def imported(self, session, task):
        """Import hook for fetching lyrics from bandcamp automatically.
        """
        if self.config['lyrics']:
            for item in task.imported_items():
                # Only fetch lyrics for items from bandcamp
                if hasattr(item, 'data_source') and item.data_source == u'bandcamp':
                    self.add_lyrics(item, True)

    def get_albums(self, query):
        """Returns a list of AlbumInfo objects for a bandcamp search query.
        """
        albums = []
        for url in self._search(query, BANDCAMP_ALBUM):
            album = self.get_album_info(url)
            if album is not None:
                albums.append(album)
        return albums

    def get_album_info(self, url):
        """Returns an AlbumInfo object for a bandcamp album page.
        """
        try:
            html = self._get(url)
            name_section = html.find(id='name-section')
            album = name_section.find(attrs={'itemprop': 'name'}).text.strip()
            # Even though there is an item_id in some urls in bandcamp, it's not
            # visible on the page and you can't search by the id, so we need to use
            # the url as id.
            album_id = url
            artist = name_section.find(attrs={'itemprop': 'byArtist'}) .text.strip()
            release = html.find('meta', attrs={'itemprop': 'datePublished'})['content']
            release = isodate.parse_date(release)
            artist_url = url.split('/album/')[0]
            tracks = []
            for row in html.find(id='track_table').find_all(attrs={'itemprop': 'tracks'}):
                track = self._parse_album_track(row)
                track.track_id = '{0}{1}'.format(artist_url, track.track_id)
                tracks.append(track)

            return AlbumInfo(album, album_id, artist, artist_url, tracks,
                             year=release.year, month=release.month,
                             day=release.day, country='XW', media='Digital Media',
                             data_source='bandcamp', data_url=url)
        except requests.exceptions.RequestException as e:
            self._log.debug("Communication error while fetching album {0!r}: "
                            "{1}".format(url, e))
        except (TypeError, AttributeError) as e:
            self._log.debug("Unexpected html while scraping album {0!r}: {1}".format(url, e))
        except BandcampException as e:
            self._log.debug('Error: {0}'.format(e))

    def get_tracks(self, query):
        """Returns a list of TrackInfo objects for a bandcamp search query.
        """
        track_urls = self._search(query, BANDCAMP_TRACK)
        return [self.get_track_info(url) for url in track_urls]

    def get_track_info(self, url):
        """Returns a TrackInfo object for a bandcamp track page.
        """
        try:
            html = self._get(url)
            name_section = html.find(id='name-section')
            title = name_section.find(attrs={'itemprop': 'name'}).text.strip()
            artist_url = url.split('/track/')[0]
            artist = name_section.find(attrs={'itemprop': 'byArtist'}).text.strip()

            try:
                duration = html.find('meta', attrs={'itemprop': 'duration'})['content']
                track_length = float(duration)
                if track_length == 0:
                    track_length = None
            except TypeError:
                track_length = None

            return TrackInfo(title, url, length=track_length, artist=artist,
                             artist_id=artist_url, data_source='bandcamp',
                             media='Digital Media', data_url=url)
        except requests.exceptions.RequestException as e:
            self._log.debug("Communication error while fetching track {0!r}: "
                            "{1}".format(url, e))

    def add_lyrics(self, item, write = False):
        """Fetch and store lyrics for a single item. If ``write``, then the
        lyrics will also be written to the file itself."""
        # Skip if the item already has lyrics.
        if item.lyrics:
            self._log.info(u'lyrics already present: {0}', item)
            return

        lyrics = self.get_item_lyrics(item)

        if lyrics:
            self._log.info(u'fetched lyrics: {0}', item)
        else:
            self._log.info(u'lyrics not found: {0}', item)
            return

        item.lyrics = lyrics

        if write:
            item.try_write()
        item.store()

    def get_item_lyrics(self, item):
        """Get the lyrics for item from bandcamp.
        """
        try:
            # The track id is the bandcamp url when item.data_source is bandcamp.
            html = self._get(item.mb_trackid)
            lyrics = html.find(attrs={'class': 'lyricsText'});
            if lyrics:
                return lyrics.text
        except requests.exceptions.RequestException as e:
            self._log.debug("Communication error while fetching lyrics for track {0!r}: "
                            "{1}".format(item.mb_trackid, e))
        return None

    def _search(self, query, search_type=BANDCAMP_ALBUM, page=1):
        """Returns a list of bandcamp urls for items of type search_type
        matching the query.
        """
        if search_type not in [BANDCAMP_ARTIST, BANDCAMP_ALBUM, BANDCAMP_TRACK]:
            self._log.debug('Invalid type for search: {0}'.format(search_type))
            return None

        try:
            urls = []
            # Search bandcamp until min_candidates results have been found or
            # we hit the last page in the results.
            while len(urls) < self.config['min_candidates'].as_number():
                self._log.debug('Searching {}, page {}'.format(search_type, page))
                results = self._get(BANDCAMP_SEARCH.format(query=query, page=page))
                clazz = u'searchresult {0}'.format(search_type)
                for result in results.find_all('li', attrs={'class': clazz}):
                    a = result.find(attrs={'class': 'heading'}).a
                    if a is not None:
                        urls.append(a['href'].split('?')[0])

                # Stop searching if we are on the last page.
                if not results.find('a', attrs={'class': 'next'}):
                    break
                page += 1

            return urls
        except requests.exceptions.RequestException as e:
            self._log.debug("Communication error while searching page {0} for {1!r}: "
                            "{2}".format(page, query, e))
            return []

    def _get(self, url):
        """Returns a BeautifulSoup object with the contents of url.
        """
        headers = {'User-Agent': USER_AGENT}
        r = requests.get(url, headers=headers)
        r.raise_for_status()
        return BeautifulSoup(r.text, 'html.parser')

    def _parse_album_track(self, track_html):
        """Returns a TrackInfo derived from the html describing a track in a
        bandcamp album page.
        """
        track_num = track_html['rel'].split('=')[1]
        track_num = int(track_num)

        title_html = track_html.find(attrs={'class': 'title-col'})
        title = title_html.find(attrs={'itemprop': 'name'}).text.strip()
        track_url = title_html.find(attrs={'itemprop': 'url'})
        if track_url is None:
            raise BandcampException('No track url (id) for track {0} - {1}'.format(track_num, title))
        track_id = track_url['href']
        try:
            duration = title_html.find('meta', attrs={'itemprop': 'duration'})['content']
            duration = duration.replace('P', 'PT')
            track_length = isodate.parse_duration(duration).total_seconds()
        except TypeError:
            track_length = None

        return TrackInfo(title, track_id, index=track_num, length=track_length)

class BandcampAlbumArt(fetchart.ArtSource):
    """Fetchart ArtSource for bandcamp albums."""

    def get(self, album):
        """Return the url for the cover from the bandcamp album page.
        This only returns cover art urls for bandcamp albums (by id).
        """
        if isinstance(album.mb_albumid, str) and u'bandcamp' in album.mb_albumid:
            try:
                headers = {'User-Agent': USER_AGENT}
                r = requests.get(album.mb_albumid, headers=headers)
                r.raise_for_status()
                album_html = BeautifulSoup(r.text, 'html.parser').find(id='tralbumArt')
                yield album_html.find('a', attrs={'class': 'popupImage'})['href']
            except requests.exceptions.RequestException as e:
                self._log.debug("Communication error getting art for {0}: {1}"
                                .format(album, e))
            except ValueError:
                pass

class BandcampException(Exception):
    pass
