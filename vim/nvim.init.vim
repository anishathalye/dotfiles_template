
" load neovim with conda env
if !empty(glob('~/anaconda3/envs/neovim/bin/python'))
    let g:python3_host_prog = expand('~/anaconda3/envs/neovim/bin/python')
endif

set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
