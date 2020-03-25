set nocompatible

" Syntax
syntax enable
filetype plugin indent on
"" Syntax for avdl
au BufRead,BufNewFile *.avdl setlocal filetype=avro-idl

" Colors
colorscheme base16-atelier-forest
if filereadable(expand("~/.vimrc_background"))
let base16colorspace=256
  source ~/.vimrc_background
endif

" Automatically read a file if it hasn't changed in vim but it changed outside vim
set autoread

" # of Context lines when scrolling
set scrolloff=15

" From sensible.vim
if v:version > 703 || v:version == 703 && has("patch541")
  set formatoptions+=j " Delete comment character when joining commented lines
endif

" Smartindent uses { and } to perform indenting
set smartindent

" Should fix backspace issues on OSX
set backspace=indent,eol,start

" Timeout for keycodes
set ttimeout
set ttimeoutlen=100

set incsearch " Incrementally search for things with /
set ignorecase " Ignore case when searching
set smartcase " Override and pay attention to case if search string isn't all-lowercase
set hlsearch " Highlight searches
nnoremap <C-k> :noh<CR> " Ctrl-k clear search highlighting

" Show Line Numbers and relativenumbers
set number
set relativenumber

" Always show statusbar
set laststatus=2

" 2 Tab Indentation
set expandtab
set shiftwidth=2
set softtabstop=2

" Don't line-break
set nowrap

" Wildmenu
" On first tab, complete longest common string and then list options
" Second tab, List options again, preventing me from entering the terrible menu
" Third tab, Finally enter the tab mode if absolutely necessary
set wildmenu
set wildmode=longest:list,list,full

" Switch to paste mode
set pastetoggle=<F2>

" Group that matches trailing whitespace except when typing at the end of a line.
highlight ExtraWhitespace ctermbg=red guibg=red
" Match on load, then let the autocommands take over
match ExtraWhitespace /\s\+$/
au InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
au InsertLeave * match ExtraWhitespace /\s\+$/

" Alt-o to close all but this buffer
" This may not work on all systems
noremap <Esc>o :only<CR>
" Same Binding for OSX
noremap ø :only<CR>

" Redraw screen mapping
nnoremap <leader>r :redraw!<CR>

let g:deoplete#enable_at_startup = 1

let g:python2_host_prog = '/usr/local/bin/python2'
let g:python3_host_prog = '/usr/local/bin/python3'

" Lets us select in between the final char and the newline
set virtualedit=onemore

" Keybindings for system clipboard
"
" Normal Mode
" \y => yy into clipboard
nmap <Leader>y "+yy
" \p => p from clipboard
nmap <Leader>p "+p
nmap <Leader>P "+p
"
" Visual Mode
" \y => yank selection into clipboard
vmap <Leader>y "+y
" \p => paste selection over visual selection
vmap <Leader>p "+p
"
" Insert Mode
" \p => paste selection at location, stay in insert mode
imap <Leader>p <Esc>"+pa
