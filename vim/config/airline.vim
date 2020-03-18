let g:airline_powerline_fonts = 1
let g:airline_theme='base16color'

let g:airline#extensions#tmuxline#enabled = 0

" This gets the parent folder name of the current repo
" Based on:
" https://github.com/kien/ctrlp.vim/blob/6e4fb3b45faf96a7fb500d2920cfeeab24aa39fb/doc/ctrlp.txt#L1237
function GetRepo()
  let cph = expand('%:p:h', 1)
  if cph =~ '^.\+://' | retu | en
  for mkr in ['.git/', '.hg/', '.svn/', '.bzr/', '_darcs/', '.vimprojects']
    let wd = call('find'.(mkr =~ '/$' ? 'dir' : 'file'), [mkr, cph.';'])
    if wd != '' | let &acd = 0 | brea | en
  endfo
  let path = wd == '' ? cph : substitute(wd, mkr.'$', '.', '')
  let repo = system('realpath '.(path).'| xargs basename -a')
  return substitute(repo, '\n\+$', '', '')
endfunction

let currentGitRepo = GetRepo()

let g:airline_section_b = "%{currentGitRepo} %{airline#util#wrap(airline#extensions#hunks#get_hunks(),0)}%{airline#util#wrap(airline#extensions#branch#get_head(),0)}"
