Dotfiles Template
=================

This is my repository for bootstraping dotfiles with [Dotbot][dotbot].

Usage
-----

This is built so it can be run any number of times and will result in the same
actions every time, so this can be added to a startup script, if desired.

To setup the dotfiles, clone this repository and run install:

    $ mkdir ~/src
    $ cd ~/src
    $ git clone git@github.com:matthew-parlette/dotfiles.git
    $ ~/src/dotfiles/install

Actions
-------

### Bash

1. Use included bashrc (may require you to rename the original ~/.bashrc
1. Set the prompt colors (part of bashrc)
1. Pull [liquidprompt][liquidprompt] repository and use it for the bash prompt (part of bashrc)

Inspiration
-----------

If you're looking for inspiration for how to structure your dotfiles or what
kinds of things you can include, you could take a look at some repos using
Dotbot.

* [anishathalye's dotfiles][anishathalye_dotfiles]
* [csivanich's dotfiles][csivanich_dotfiles]
* [m45t3r's dotfiles][m45t3r_dotfiles]
* [alexwh's dotfiles][alexwh_dotfiles]
* [azd325's dotfiles][azd325_dotfiles]

If you're using Dotbot and you'd like to include a link to your dotfiles here
as an inspiration to others, please submit a pull request.

License
-------

This software is hereby released into the public domain. That means you can do
whatever you want with it without restriction. See `LICENSE.md` for details.

That being said, I would appreciate it if you could maintain a link back to
Dotbot (or this repository) to help other people discover Dotbot.

[dotbot]: https://github.com/anishathalye/dotbot
[liquidprompt]: https://github.com/nojhan/liquidprompt
[anishathalye_dotfiles]: https://github.com/anishathalye/dotfiles
[csivanich_dotfiles]: https://github.com/csivanich/dotfiles
[m45t3r_dotfiles]: https://github.com/m45t3r/dotfiles
[alexwh_dotfiles]: https://github.com/alexwh/dotfiles
[azd325_dotfiles]: https://github.com/Azd325/dotfiles
