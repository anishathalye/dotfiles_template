" Ctrl-F => MRU Files
nnoremap <C-f> :CtrlPMRUFiles<CR>

" Ignores files in .gitignore
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
