# Github Tools for Sublime Text #

## Introduction ##

A set of handy tools for using Sublime Text editor with [Github](http://github.com). It was initially developed for Sublime Text 2, but now also supports Sublime Text 3 Beta.

If you're a [Beanstalk](http://beanstalkapp.com) user, check out [Beanstalk Tools for Sublime Text](https://github.com/temochka/sublime-text-2-beanstalk).

## Usage ##

Open any directory of your GIT working copy in Sublime Text.

* Press `Ctrl + Shift + P` and select `Github: Open File` or just press `Ctrl + Shift + ^` to open currently edited file on Github.
* Press `Ctrl + Shift + P` and select `Github: Blame` to open blame for currently edited file on Github.
* Press `Ctrl + Shift + P` and select `Github: Copy Link To File` to save a Github link to a selected code fragment in the system clipboard.
* Press `Ctrl + Shift + P` and select `Github: Repository` to open repository page on Github.
* Press `Ctrl + Shift + P` and select `Github: Issues` to open repository issues page on Github.
* Press `Ctrl + Shift + P` and select `Github: Pull Requests` to open repository pull requests page on Github.

Use `Cmd` instead of `Ctrl` on Mac OS X.

## Get it installed ##

### With The Package Control Plugin ###

Press `Ctrl + Shift + P` to open the Command Palette type `pack install`, search for Github Tools and press enter.

Use `Cmd` instead of `Ctrl` on Mac OS X.

### On Mac ###

```bash
cd ~/Library/Application\ Support/Sublime\ Text\ 2/Packages/
git clone git://github.com/temochka/sublime-text-2-github-tools.git
```

### On Linux ###

```bash
cd ~/.config/sublime-text-2/Packages/
git clone git://github.com/temochka/sublime-text-2-github-tools.git
```

### On Windows ###

```
cd %APPDATA%/Sublime Text 2/Packages/
git clone git://github.com/temochka/sublime-text-2-github-tools.git
```

Make sure you have included all required binaries (`git`) in your PATH.
