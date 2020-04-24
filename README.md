Dotfiles
========

My dotfiles repo.

Requirements
------------

* fedora enviroment
* Systemd

Installation
------------

* `git clone https://github.com/kraigmckernan/dotfiles.git`
* `cd dotfiles && ./install`

Other Setup Requirements
------------------------

* Update `./git/workconfig` with name and email you want to default to in `~/git/`
* Firefox bookmarks(firefox/bookmarks.json)(Empty right now, fill in with blank one as we go)
* Firefox plugins
  * Vimium(config at firefox/vimium.json)
  * Tab Reloader
* keepassx with DB in google drive
* Setup vpn with NetworkManager
* Save ssh-key password in agent
* Handle power key button press using `/etc/systemd/logind.conf`
* Update randr configs with arandr, update i3 monitor configs to match
* Install DBeaver, using PEM based public key if needed
* Add wallpapers to ~/Pictures/wallpapers/\*
* Install slack

Details
-------

* Terminal: `tilix`, {Win + return}
* drun: `rofi`, {Win + d}
* Window Manager: `i3-gaps`, Load through login session
* Bar: `polybar`
* Browser: `firefox`
* Terminal Window Manager: `tmux`
* Tmux config: tmuxifier - `windows $DIR`, `new-window $DIR`
* Editor: Neovim - `nvim`
* Font: [Cousine for Powerline](https://github.com/powerline/fonts/tree/master/Cousine)
* Colorscheme: [Base16 Atelier Forest Dark for tilix](https://github.com/karlding/base16-tilix)
* AudioControl: `pavucontrol`
* Network control: NetworkManager-tui - `nmtui`
* Communication: Slack


License
-------

### Copied from dotbot

* [dotbot](https://github.com/anishathalye/dotbot)
* [dotbot-users](https://github.com/anishathalye/dotbot/wiki/Users)
* [template](https://github.com/anishathalye/dotfiles_template)

This software is hereby released into the public domain. That means you can do
whatever you want with it without restriction. See `LICENSE.md` for details.
