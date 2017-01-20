" pathogen
" runtime bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()

" filetype plugin on

" set autoindent
set autoread

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set cindent
set completeopt=menu,longest,preview
set confirm

set expandtab

set hid             " allow switching buffers, which have unsaved changes
set history=50      " keep 50 lines of command line history

set ignorecase      " ignore case
set incsearch       " do incremental searching

" set mouse=a       " use mouse in xterm to scroll

set nobackup        " DON'T keep a backup file
set nocompatible
set number          " line numbers

set ruler           " show the cursor position all the time

set scrolloff=5     " 5 lines bevore and after the current line when scrolling
set shiftwidth=2    " 2 characters for indenting
set showcmd         " display incomplete commands
set showmatch       " showmatch: Show the matching bracket for the last ')'?
set smartcase       " don't ignore case, when search string contains uppercase letters

set tabstop=2
set textwidth=72

" Vundle
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle, required
Plugin 'gmarik/vundle'

" Bundles
Bundle 'edthedev/minion'
