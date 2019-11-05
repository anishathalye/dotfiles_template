# beets-bandcamp

Plugin for [beets](https://github.com/sampsyo/beets) to use bandcamp as an
autotagger source.

## Installation

1. Clone this project, or download `bandcamp.py`, in your configured pluginpath (e.g., `~/.beets`)
2. Add `bandcamp` to your configured beets plugins

## Configuration

* **``lyrics``** If this is `true` the plugin will add lyrics to the tracks if 
  they are available. Default is `false`.

* **``art``** If this is `true` the plugin will add a source to the
  [FetchArt](http://beets.readthedocs.org/en/latest/plugins/fetchart.html)
  plugin to download album art for bandcamp albums (you need to enable the
  [FetchArt](http://beets.readthedocs.org/en/latest/plugins/fetchart.html)
  plugin).  Default is `false`.

## Dependencies

* [requests](https://github.com/kennethreitz/requests)

* [beautifulsoup](http://www.crummy.com/software/BeautifulSoup)

* [isodate](https://github.com/gweis/isodate)

You can install the dependencies with

```
$ pip install requests beautifulsoup4 isodate
```
