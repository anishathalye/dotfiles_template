Dotfiles Template
=================

This is a template repository for bootstraping your dotfiles with [Dotbot][1].

To get started, you can [fork][2] this repository (and probably delete this
README and rename your version to something like just `dotfiles`).

In general, you should be using symbolic links for everything, and using git
submodules whenever possible.

To keep submodules at their proper versions, you could include something like
`git submodule update --init --recursive` in your `install.conf.json`.

To upgrade your submodules to their latest versions, you could periodically run
something like the following.

```bash
git submodule foreach 'git checkout master && git pull && cd "${toplevel}" && git add ":/${path}"'
```

Inspiration
-----------

If you're looking for inspiration for how to structure your dotfiles or what
kinds of things you can include, you could take a look at some repos using
Dotbot.

* [anishathalye's dotfiles][3]
* [csivanich's dotfiles][4]

If you're using Dotbot and you'd like to include a link to your dotfiles here
as an inspiration to others, please submit a pull request.

License
-------

This software is released into the public domain. That means you can do
whatever you want with it without restriction.

That being said, I would appreciate it if you could maintain a link back to
Dotbot (or this repository) to help other people discover Dotbot.

[1]: https://github.com/anishathalye/dotbot
[2]: https://github.com/anishathalye/dotfiles_template/fork
[3]: https://github.com/anishathalye/dotfiles
[4]: https://github.com/csivanich/dotfiles
