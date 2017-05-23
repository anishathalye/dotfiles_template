" pathogen
runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()
syntax on
filetype plugin on

set autoread        " set autoindent

set backspace=indent,eol,start  " allow backspacing over everything in insert mode
set backup

set cindent
set completeopt=menu,longest,preview
set confirm

set expandtab

set hid             " allow switching buffers, which have unsaved changes
set history=50      " keep 50 lines of command line history

set ignorecase      " ignore case
set incsearch       " do incremental searching

" set mouse=a       " use mouse in xterm to scroll

set nocompatible
set number          " line numbers

set omnifunc=syntaxcomplete#Complete  " omni completion

set ruler           " show the cursor position all the time

set scrolloff=5     " 5 lines before and after the current line when scrolling
set shiftwidth=2    " 2 characters for indenting
set showcmd         " display incomplete commands
set showmatch       " showmatch: Show the matching bracket for the last ')'?
set smartcase       " don't ignore case, when search string contains uppercase letters

set tabstop=2
set textwidth=72

set writebackup

colorscheme torte

" Vimwiki
let g:vimwiki_list = [{'path': '~/Documents/vimwiki/', 'auto_export': 1}]

