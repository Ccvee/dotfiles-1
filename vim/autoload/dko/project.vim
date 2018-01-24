" ============================================================================
" DKO Project
"
" Helpers to finds config files for a project (e.g. linting RC files) relative
" to a git repo root.
"
" Similar to what this plugin does, but using a single system call to `git`
" instead of using `expand()` with `:h` to traverse up directories.
" https://github.com/dbakker/vim-projectroot/blob/master/autoload/projectroot.vim
"
" Settings:
" b:dko_project_roots [array] - look for config files in this array of
"                              directory names relative to the project
"                              root if it is set
" g:dko_project_roots [array] - global overrides
" ============================================================================

let s:cpo_save = &cpoptions
set cpoptions&vim

" ============================================================================
" Default Settings
" ============================================================================

" Look for project config files in these paths
let s:default_roots = [
      \   '',
      \   'config/',
      \ ]

" Look for project root using these file markers if not a git project
let s:markers = [
      \   'package.json',
      \   'composer.json',
      \   'requirements.txt',
      \   'Gemfile',
      \ ]

" ============================================================================
" Project root resolution
" ============================================================================

" Buffer-cached project root, prefer based on file markers
"
" @param {String} [file] from which to look upwards
" @return {String} project root path or empty string
function! dko#project#GetRoot(...) abort
  let l:bufnr = a:0 && type(a:1) == v:t_dict && a:1['bufnr']
        \ ? a:1['bufnr'] : '%'
  let l:existing = getbufvar(l:bufnr, 'dko_project_root')
  if !empty(l:existing) | return l:existing | endif

  " Look for markers FIRST, that way we support things like browsing through
  " node_modules/ and monorepos
  let l:root = dko#project#GetRootByFileMarker(s:markers)

  " Try git root
  " Always sets gitroot
  let l:path = dko#project#GetFilePath(get(a:, 1, ''))
  let l:gitroot = dko#project#GetGitRootByFile(l:path)
  if !empty(l:gitroot)
    let b:dko_project_gitroot = l:gitroot
    if empty(l:root) | let l:root = l:gitroot | endif
  endif

  let b:dko_project_root = l:root
  return b:dko_project_root
endfunction

function! dko#project#SetRoot(root) abort
  let b:dko_project_root = a:root
endfunction

" @return {Boolean} if gitroot and project root differ
function! dko#project#IsMonorepo() abort
  if empty(dko#project#GetRoot()) | return 0 | endif
  return b:dko_project_root !=# get(b:, 'dko_project_gitroot', '')
endfunction

" @param {String} file to get path to
" @return {String} path to project root
function! dko#project#GetFilePath(file) abort
  " Argument
  " Path for given file
  let l:path = get(a:, 'file')
        \ ? fnamemodify(resolve(expand(a:file)), ':p:h')
        \ : ''

  " Fallback to current file if no argument
  " Try current file's path
  let l:path = empty(l:path) && filereadable(expand('%'))
        \ ? expand('%:p:h')
        \ : l:path

  " Fallback if no current file
  " File was not readable so just use current path buffer started from
  let l:path = empty(l:path) ? getcwd() : l:path

  " Special circumstances
  " Go up one level if INSIDE the .git/ dir
  let l:path = fnamemodify(l:path, ':t') ==# '.git'
        \ ? fnamemodify(l:path, ':p:h:h')
        \ : l:path

  return l:path
endfunction

" Buffer-cached gitroot
"
" @param {String} path
" @return {String} git root of file or empty string
function! dko#project#GetGitRootByFile(path) abort
  if exists('b:dko_project_gitroot') | return b:dko_project_gitroot | endif
  let l:std = split(
        \ system('cd -- ' . a:path . ' && git rev-parse --show-toplevel 2>/dev/null'),
        \ '\n'
        \ )
  let b:dko_project_gitroot = v:shell_error || empty(l:std) ? '' : l:std[0]
  return b:dko_project_gitroot
endfunction

" @param {String[]} markers
" @return {String} root path based on presence of file marker
function! dko#project#GetRootByFileMarker(markers) abort
  let l:result = ''
  for l:marker in a:markers
    " Try to use nearest first; findfile .; goes from current file upwards
    let l:filepath = findfile(l:marker, '.;')
    if empty(l:filepath) | continue | endif
    let l:result = fnamemodify(resolve(expand(l:filepath)), ':p:h')
  endfor
  return l:result
endfunction

" @return {String}
function! dko#project#Type() abort
  if expand('%:p') =~? 'content/\(mu-plugins\|plugins\|themes\)'
    return 'wordpress'
  endif
  return ''
endfunction

" Get array of possible config file paths for a project -- any dirs where
" files like .eslintrc, package.json, etc. might be stored. These will be
" paths relative to the root from dko#project#GetRoot
"
" @return {String[]} config paths relative to dko#project#GetRoot
function! dko#project#GetPaths() abort
  return get(
        \   b:, 'dko#project#roots', get(
        \   g:, 'dko#project#roots',
        \   s:default_roots
        \ ))
endfunction

" Get full path to a dir in a project
"
" @param {String} dirname
" @return {String} full path to dir
function! dko#project#GetDir(dirname) abort
  if empty(dko#project#GetRoot()) | return '' | endif

  for l:root in dko#project#GetPaths()
    let l:current =
          \ expand(dko#project#GetRoot() . '/' . l:root)

    if !isdirectory(l:current)
      continue
    endif

    if isdirectory(glob(l:current . a:dirname))
      return l:current . a:dirname
    endif
  endfor

  return ''
endfunction

" Get full path to a file in a project
" Look in local project first, then in git root
"
" @param {String} filename
" @return {String} full path to config file
function! dko#project#GetFile(filename) abort
  if empty(dko#project#GetRoot()) | return '' | endif

  let l:root = dko#project#IsMonorepo()
        \ ? get(b:, 'dko_project_gitroot', dko#project#GetRoot())
        \ : dko#project#GetRoot()

  " Try to use nearest first; up to the root
  let l:bounds = fnamemodify(a:filename, ':p:h') . ';' . l:root
  let l:nearest = findfile(a:filename, l:bounds)
  if !empty(l:nearest) | return l:nearest | endif

  " @FIXME
  " Look in local paths for the project (not including git root)
  for l:root in dko#project#GetPaths()
    let l:current = expand(l:root . '/' . l:root)
    if !isdirectory(l:current) | continue | endif
    if filereadable(glob(l:current . a:filename))
      return l:current . a:filename
    endif
  endfor

  return ''
endfunction

" Get bin local to project
"
" @param {String} bin path relative to project root
" @return {String}
function! dko#project#GetBin(bin) abort
  if empty(a:bin) | return '' | endif

  " Use cached
  let l:bins = dko#InitDict('b:dko_project_bins')
  if !empty(get(l:bins, a:bin)) | return l:bins[a:bin] | endif

  " Use found
  let l:exe = dko#project#GetFile(a:bin)
  if !empty(l:exe) && executable(l:exe)
    let l:bins[a:bin] = l:exe
    return l:exe
  endif

  return ''
endfunction

function! dko#project#GetCandidate(candidates) abort
  let l:candidates = map(copy(a:candidates), 'dko#project#GetFile(v:val)')
  return call('dko#First', l:candidates)
endfunction

" ============================================================================

let &cpoptions = s:cpo_save
unlet s:cpo_save
