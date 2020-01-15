" autoload/dko/neomake/markdown.vim

function! dko#neomake#markdown#Setup() abort
  let l:safeft = neomake#utils#get_ft_confname(&filetype)
  if exists('b:did_dkoneomake_' . l:safeft) | return | endif
  let b:did_dkoneomake_{l:safeft} = 1

  call dko#neomake#NpxMaker(extend(
        \   neomake#makers#ft#markdown#alex(), {
        \     'ft': 'markdown',
        \     'maker': 'alex',
        \     'cwd': dko#project#GetRoot(),
        \   }))
endfunction

