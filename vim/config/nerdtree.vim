" Toggle Nerd Tree
map <leader>n :NERDTreeToggle<CR>

" Find current file in NT
map <leader>f :NERDTreeFind<CR>
" Open CWD in NT
map <leader>c :NERDTreeCWD<CR>

let g:NERDTreeDirArrowExpandable='+'
let g:NERDTreeDirArrowCollapsible='-'

" Close vim if NERDTree is last window open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
