" Ctrl-F => MRU Files
nnoremap <C-f> :CtrlPMRUFiles<CR>
nnoremap <C-g> :CtrlPRoot<CR>

" Ignores files in .gitignore
let g:ctrlp_user_command = {
\   'types': {
\     1: ['.git', 'cd %s && git ls-files -co --exclude-standard'],
\     2: ['.src_dir', 'cd %s && ag -l --nocolor ".*"'],
\   }
\ }

" Lets us load ALL the files
let g:ctrlp_max_files=0
let g:ctrlp_max_depth=50

" Default ctrlp behavior is to take the current open file and use the closest
" parent .git folder to use as the root.
" This line changes ctrlp to believe the working directory is *actually* the
" working path that vim uses. Cool cool cool.
let g:ctrlp_working_path_mode = ''
