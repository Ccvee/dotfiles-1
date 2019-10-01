" plugin/completion.vim

augroup dkocompletion
  autocmd!
augroup END

if !dkoplug#IsLoaded('coc.nvim') && !dkoplug#IsLoaded('neosnippet')
  finish
endif

let s:cpo_save = &cpoptions
set cpoptions&vim

" ============================================================================
" Neosnippet
" ============================================================================

if dkoplug#IsLoaded('neosnippet')
  let g:neosnippet#snippets_directory = g:dko#vim_dir . '/snippets'
  let g:neosnippet#enable_snipmate_compatibility = 1
  let g:neosnippet#enable_conceal_markers = 0
  let g:neosnippet#scope_aliases = {}
  let g:neosnippet#scope_aliases['javascript'] = join([
        \   'javascript',
        \   'javascript.jsx',
        \   'javascript.es6.react',
        \ ], ',')

  " Get rid of the placeholders in inserted snippets when done inserting
  autocmd dkocompletion InsertLeave * NeoSnippetClearMarkers

  silent! iunmap <C-f>
  silent! sunmap <C-f>
  silent! xunmap <C-f>

  " Insert js/phpdoc block
  nnoremap <silent><special>
        \ <Leader>pd
        \ O<Esc>a<C-r>=neosnippet#expand('doc')<CR>

  " Keybindings for snippet completion
  imap  <C-f>   <Plug>(neosnippet_expand_or_jump)
  smap  <C-f>   <Plug>(neosnippet_expand_or_jump)
  xmap  <C-f>   <Plug>(neosnippet_expand_target)
endif

" ============================================================================
" coc.nvim
" ============================================================================

if dkoplug#IsLoaded('coc.nvim')
  call coc#add_extension(
        \  'coc-css',
        \  'coc-diagnostic',
        \  'coc-eslint',
        \  'coc-git',
        \  'coc-html',
        \  'coc-json',
        \  'coc-neosnippet',
        \  'coc-prettier',
        \  'coc-pyright',
        \  'coc-snippets',
        \  'coc-syntax',
        \  'coc-tsserver',
        \  'coc-vimlsp',
        \  'coc-webpack',
        \  'coc-yaml'
        \)
  " Not working
  "      \  'coc-python',
  "      \  'coc-java',
  " Doesn't redraw in sync with edits
  "\  'coc-highlight',

  let g:coc_enable_locationlist = 0
  let g:coc_snippet_next = '<C-f>'
  let g:coc_snippet_prev = '<C-b>'

  autocmd dkocompletion User CocNvimInit call s:MarkExtensions()

  function! s:ShowDocumentation()
    if &filetype ==# 'vim'
      execute 'h ' . expand('<cword>')
    else
      call CocActionAsync('doHover')
    endif
  endfunction

  inoremap <silent><expr> <C-Space> coc#refresh()

  nmap <silent> <Leader>d <Plug>(coc-diagnostic-info)
  nmap <silent> ]d <Plug>(coc-diagnostic-next)
  nmap <silent> [d <Plug>(coc-diagnostic-prev)

  nmap <silent> gh <Plug>(coc-declaration)

  " value
  nmap <silent> gd <Plug>(coc-definition)

  " instance
  nmap <silent> gi <Plug>(coc-implementation)

  nmap <silent> <Leader>t <Plug>(coc-type-definition)
  nnoremap <silent> K :<C-U>call <SID>ShowDocumentation()<CR>

  nmap <silent> <Leader>= <Plug>(coc-format-selected)
  vmap <silent> <Leader>= <Plug>(coc-format-selected)

  autocmd dkocompletion FileType
        \ javascript,javascriptreact,typescript,typescriptreact,json,graphql
        \ nmap <silent> <A-=>
        \   :<C-u>CocCommand prettier.formatFile<CR>
        "\   :CocCommand eslint.executeAutofix<CR>

  " coc-git
  nnoremap <silent> <Leader>g :<C-u>CocCommand git.toggleGutters<CR>
  nmap [g <Plug>(coc-git-prevchunk)
  nmap ]g <Plug>(coc-git-nextchunk)
endif

" ============================================================================

let &cpoptions = s:cpo_save
unlet s:cpo_save
