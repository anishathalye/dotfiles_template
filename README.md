This is a repo with all the various dotfiles I use accross local and remote machines

It uses:
* Shell tools
  * zsh (via [zplug](https://github.com/zplug/zplug))
  * tmux (via [tpm](https://github.com/tmux-plugins/tpm))
  * [fzf](https://github.com/junegunn/fzf)
  * [autojump](https://github.com/wting/autojump) j (z is disabled)
  * midnight commander
  * find (fd, ag, [ripgrep](https://github.com/BurntSushi/ripgrep))
* [vim-plug](https://github.com/junegunn/vim-plug)
* git tools
  * [tig](https://github.com/jonas/tig)
  * [forgit](https://github.com/wfxr/forgit) (glo, gla, gd)
* [lnav](https://github.com/tstack/lnav)
* [linuxbrew](https://docs.brew.sh/Homebrew-on-Linux)
* [cheat](https://github.com/chrisallenlane/cheat)
* [pgcli](https://www.pgcli.com/) (psql client with fuzzy search)
* [colorls](https://github.com/athityakumar/colorls)
* [powerline fonts](https://github.com/powerline/fonts)
* [nerds-fonts](https://github.com/ryanoasis/nerd-fonts/blob/master/readme.md#font-installation)
* [dotbot](https://github.com/anishathalye/dotbot)

## Installation

### 1) Remote machine 
for a remote machine (without sudo access), simply run
```bash
curl -L https://raw.githubusercontent.com/lbesnard/dotfiles/master/initsys.sh | bash
```

This will install [linuxbrew](https://docs.brew.sh/Homebrew-on-Linux), and then install in the home dir
various tools such as Ansible. The above tools will also be installed.

### 2) Local machine

This is highly dependent on https://github.com/lbesnard/ansible_laptop which will
automatically install the dotfiles.

However it is possible to clone the repo and install it manually
```bash
git clone git@github.com:lbesnard/dotfiles.git
cd dotfiles
./install
```
