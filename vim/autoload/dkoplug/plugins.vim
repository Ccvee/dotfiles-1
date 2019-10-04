" autoload/dkoplug/plugins.vim

" Similar but safer than Cond() from
" <https://github.com/junegunn/vim-plug/wiki/faq>
" This is a global function for command access
function! PlugIf(condition, ...) abort
  let l:enabled = a:condition ? {} : { 'on': [], 'for': [] }
  return a:0 ? extend(l:enabled, a:000[0]) : l:enabled
endfunction

" Shortcut
function! WithCompl(...) abort
  return call('PlugIf', [ g:dko_use_completion ] + a:000)
endfunction

function! dkoplug#plugins#LoadAll() abort
  " Notes on adding plugins:
  " - Absolutely do not use 'for' if the plugin provides an `ftdetect/`

  " ==========================================================================
  " Vim debugging
  " ==========================================================================

  " Show slow plugins
  Plug 'tweekmonster/startuptime.vim', { 'on': [ 'StartupTime' ] }

  " `:Bufferize messages` to get messages (or any :command) in a new buffer
  let g:bufferize_command = 'tabnew'
  Plug 'AndrewRadev/bufferize.vim', { 'on': [ 'Bufferize' ] }

  Plug 'cocopon/colorswatch.vim', { 'on': [ 'ColorSwatchGenerate' ] }

  silent! nunmap zs
  nnoremap <silent> zs :<C-U>Inspecthi<CR>
  Plug 'cocopon/inspecthi.vim', { 'on': [ 'Inspecthi' ] }

  " ==========================================================================
  " Colorscheme
  " ==========================================================================

  if isdirectory(expand('~/projects/vim-colors-meh'))
    Plug expand('~/projects/vim-colors-meh')
  else
    Plug 'davidosomething/vim-colors-meh'
  endif
  Plug 'rakr/vim-two-firewatch'
  Plug 'kamwitsta/flatwhite-vim'

  " ==========================================================================
  " Embedded filetype support
  " ==========================================================================

  " tyru/caw.vim, some others use this to determine inline embedded filetypes
  Plug 'Shougo/context_filetype.vim'

  " ==========================================================================
  " Commands
  " ==========================================================================

  " Use the repo instead of the version in brew since it includes the help
  " docs for fzf#run()
  Plug 'junegunn/fzf', PlugIf(g:dko_use_fzf)

  let g:dko_fzf_modal = 0 && has('nvim-0.4')
  let g:fzf_command_prefix = 'FZF'
  let g:fzf_layout = extend({ 'down': '~40%' }, g:dko_fzf_modal
        \   ? { 'window': 'call dko#Modal()' }
        \   : {}
        \ )
  let g:fzf_buffers_jump = 1
  Plug 'junegunn/fzf.vim', PlugIf(g:dko_use_fzf)

  Plug 'lambdalisue/gina.vim', PlugIf(exists('v:null'), {
        \   'on': [ 'Gina', '<Plug>(gina' ]
        \ })

  " :Bdelete to preserve windows (mapped to <Leader>x)
  Plug 'moll/vim-bbye'

  Plug 'nathanaelkane/vim-indent-guides'

  Plug 'osyo-manga/vim-over', { 'on': [ 'OverCommandLine' ] }

  let g:git_messenger_max_popup_width = 60
  Plug 'rhysd/git-messenger.vim', PlugIf(exists('*nvim_win_set_config'), {
        \   'on': [ 'GitMessenger', '<Plug>(git-messenger' ],
        \ })

  Plug 'sbdchd/neoformat'

  " Add file manip commands like Remove, Move, Rename, SudoWrite
  " Do not lazy load, tracks buffers
  Plug 'tpope/vim-eunuch'

  " <C-w>o to zoom in/out of a window
  "Plug 'dhruvasagar/vim-zoom'
  " Better zoom plugin, accounts for command window and doesn't use sessions
  Plug 'troydm/zoomwintab.vim'

  " ==========================================================================
  " Input, syntax, spacing
  " ==========================================================================

  "Plug 'sgur/vim-editorconfig'

  " highlight matching html/xml tag
  "Plug 'gregsexton/MatchTag'
  let g:matchup_delim_noskips = 2
  let g:matchup_matchparen_deferred = 1
  let g:matchup_matchparen_status_offscreen = 0
  Plug 'andymass/vim-matchup', PlugIf(has('patch-7.4.1689'))

  " add gS on char to smart split lines at char, like comma lists and html tags
  Plug 'AndrewRadev/splitjoin.vim'

  " Compatible with Neovim or Vim with this patch level
  Plug 'neomake/neomake', PlugIf(has('patch-7.4.503'))
  "Plug '~/projects/neomake'

  " ==========================================================================
  " Editing keys
  " ==========================================================================

  Plug 'arp242/jumpy.vim'

  "Plug 'cyansprite/Extract', PlugIf(has('nvim'))
  Plug 'svermeulen/vim-yoink', PlugIf(has('nvim'))

  Plug 'godlygeek/tabular', { 'on': [ 'Tabularize' ] }

  Plug 'bootleq/vim-cycle', { 'on': [ '<Plug>Cycle' ] }

  Plug 'tpope/vim-repeat'

  " []-bindings -- buffer switch, lnext/prev, etc.
  " My fork has a lot of removals like line movement and entities
  Plug 'davidosomething/vim-unimpaired'

  Plug 'machakann/vim-highlightedyank'

  " used for line bubbling commands (instead of unimpared!)
  " Consider also t9md/vim-textmanip
  Plug 'matze/vim-move'

  Plug 'kana/vim-operator-user'
  " gcc to toggle comment
  Plug 'tyru/caw.vim', { 'on': [ '<Plug>(caw' ] }
  " <Leader>s(a/r/d) to modify surrounding the pending operator
  Plug 'rhysd/vim-operator-surround', { 'on': [ '<Plug>(operator-surround' ] }
  " <Leader>c to toggle CamelCase/snak_e the pending operator
  Plug 'tyru/operator-camelize.vim', { 'on': [ '<Plug>(operator-camelize' ] }

  " Some textobjs are lazy loaded since they are ~4ms slow to load.
  " See plugin/textobj.vim to see how they're mapped.
  " -       Base textobj plugin
  Plug 'kana/vim-textobj-user'
  " - d/D   for underscore section (e.g. `did` on foo_b|ar_baz -> foo__baz)
  Plug 'machakann/vim-textobj-delimited', { 'on': [
        \   '<Plug>(textobj-delimited'
        \ ] }
  " - i     for indent level
  Plug 'kana/vim-textobj-indent', { 'on': [ '<Plug>(textobj-indent' ] }
  " - l     for current line
  Plug 'kana/vim-textobj-line', { 'on': [ '<Plug>(textobj-line' ] }
  " - P     for last paste
  Plug 'gilligan/textobj-lastpaste', { 'on': [ '<Plug>(textobj-lastpaste' ] }
  " - u     for url
  Plug 'mattn/vim-textobj-url', { 'on': [ '<Plug>(textobj-url' ] }
  " - b     for any block type (parens, braces, quotes, ltgt)
  Plug 'rhysd/vim-textobj-anyblock'
  " - x     for xml attr like `data-content="everything"`
  Plug 'whatyouhide/vim-textobj-xmlattr', { 'on': [
        \   '<Plug>(textobj-xmlattr',
        \ ] }

  " HR with <Leader>f[CHAR]
  Plug g:dko#vim_dir . '/mine/vim-hr'

  " <Leader>C <Plug>(dkosmallcaps)
  Plug g:dko#vim_dir . '/mine/vim-smallcaps', { 'on': [
        \   '<Plug>(dkosmallcaps)',
        \ ] }

  " Toggle movement mode line-wise/display-wise
  Plug g:dko#vim_dir . '/mine/vim-movemode'

  " ==========================================================================
  " Completion
  " ==========================================================================

  " --------------------------------------------------------------------------
  " Signature preview
  " --------------------------------------------------------------------------

  Plug 'Shougo/echodoc.vim'

  " --------------------------------------------------------------------------
  " Snippet engine
  " --------------------------------------------------------------------------

  Plug 'Shougo/neosnippet', WithCompl()
  Plug 'Shougo/neosnippet-snippets', WithCompl()
  Plug 'honza/vim-snippets', WithCompl()

  " --------------------------------------------------------------------------
  " Completion engine
  " --------------------------------------------------------------------------

  Plug 'neoclide/coc.nvim', WithCompl({ 'branch': 'release' })

  " --------------------------------------------------------------------------
  " Completion libraries
  " --------------------------------------------------------------------------

  " Include completion, include tags
  " For what langs are supported, see:
  " https://github.com/Shougo/neoinclude.vim/blob/master/autoload/neoinclude.vim
  Plug 'Shougo/neoinclude.vim', WithCompl()
  Plug 'jsfaint/coc-neoinclude'

  " ==========================================================================
  " Multiple languages
  " ==========================================================================

  " autoclose parens and blocks in various langs
  "Plug 'tpope/vim-endwise'
  " let g:lexima_enable_basic_rules = 0 " only on <CR>
  "Plug 'cohama/lexima.vim' " Doesn't detect distant closer if whitespace
  "Plug 'Raimondi/delimitMate' " Doesn't indent properly on <CR>
  " let g:AutoPairsShortcutToggle = ''
  " let g:AutoPairsShortcutFastWrap = ''
  " Plug 'jiangmiao/auto-pairs'

  Plug 'suy/vim-context-commentstring'

  " ==========================================================================
  " Language: ansible config
  " ==========================================================================

  " ft specific stuff only
  Plug 'pearofducks/ansible-vim'

  " ==========================================================================
  " Language: bash/shell/zsh
  " ==========================================================================

  " Upstreams
  Plug 'chrisbra/vim-sh-indent'
  Plug 'chrisbra/vim-zsh'

  " ==========================================================================
  " Language: D
  " ==========================================================================

  Plug 'idanarye/vim-dutyl', { 'for': [ 'd' ] }

  " ==========================================================================
  " Language: Git
  " ==========================================================================

  " creates gitconfig, gitcommit, rebase
  " provides :DiffGitCached in gitcommit file type
  " vim 7.4-77 ships with 2013 version, this is newer
  Plug 'tpope/vim-git'

  " show diff when editing a COMMIT_EDITMSG
  Plug 'rhysd/committia.vim'

  " committia for git rebase -i
  "Plug 'hotwatermorning/auto-git-diff'

  " ==========================================================================
  " Language: HTML, XML, and generators: mustache, handlebars
  " ==========================================================================

  " Syntax enhancements and htmlcomplete#CompleteTags function override
  "Plug 'othree/html5.vim'

  "Plug 'tpope/vim-haml'

  " Creates html.handlebars and other fts and sets syn
  Plug 'mustache/vim-mustache-handlebars'

  " ==========================================================================
  " Language: JavaScript and derivatives, JSON
  " ==========================================================================

  Plug g:dko#vim_dir . '/mine/vim-pj'

  " Order of these two matters
  "Plug 'elzr/vim-json'
  Plug 'neoclide/jsonc.vim'

  " provides coffee ft
  "Plug 'kchmck/vim-coffee-script', { 'for': [ 'coffee' ] }
  " The upstream has after/* garbage that messes with <script> html blocks in
  " php files
  Plug 'davidosomething/vim-coffee-script', {
        \   'for':    [ 'coffee' ],
        \   'branch': 'noft'
        \ }

  " TypeScript
  "Plug 'leafgarland/typescript-vim'
  " Alternatively
  Plug 'HerringtonDarkholme/yats.vim'

  " ----------------------------------------
  " Syntax
  " ----------------------------------------

  " Common settings for vim-javascript, vim-jsx-improve
  " let g:javascript_plugin_flow = 0
  let g:javascript_plugin_jsdoc = 1

  " COMBINED AND MODIFIED pangloss + vim-jsx-pretty
  " Not well maintained
  "Plug 'neoclide/vim-jsx-improve'

  " PANGLOSS MODE - this is vim upstream now!
  " 1.  Preferring pangloss for now since I like the included indentexpr
  "     it also has a node ftdetect
  " 2.  After syntax, ftplugin, indent for JSX
  Plug 'pangloss/vim-javascript'

  " YAJS MODE
  " 1.  yajs.vim highlighting is a little more robust than the pangloss one.
  " 2.  The libraries syntax adds unique highlighting for
  "     jQuery,backbone,etc. and I've confirmed it is only compatible with
  "     yajs.vim as of 2016-11-03.
  " 3.  es.next support has possible jsx indent conflicts
  "     @see https://github.com/othree/es.next.syntax.vim/issues/5
  " Plug 'othree/yajs.vim'
  " Plug 'othree/javascript-libraries-syntax.vim'
  " Plug 'othree/es.next.syntax.vim'

  " ----------------------------------
  " JSX
  " ----------------------------------

  " Works with both pangloss/othree
  " Offers inline code highlighting in JSX blocks, as well as vim-jsx's hi
  Plug 'maxmellon/vim-jsx-pretty'

  " ----------------------------------
  " Template strings
  " ----------------------------------

  " `:JsPreTmpl html` to highlight `<div></div>` template strings
  "Plug 'Quramy/vim-js-pretty-template'

  " ----------------------------------
  " GraphQL
  " ----------------------------------

  Plug 'jparise/vim-graphql'

  " ==========================================================================
  " Language: Markdown, Pandoc
  " ==========================================================================

  " Override vim included markdown ft* and syntax
  " The git repo has a newer syntax file than the one that ships with vim
  Plug 'tpope/vim-markdown'

  " after/syntax for GitHub emoji, checkboxes
  Plug 'rhysd/vim-gfm-syntax'

  " Enable pandoc filetype options and vim operators/fns
  " Plug 'vim-pandoc/vim-pandoc', PlugIf(v:version >= 704)

  " Use pandoc for markdown syntax
  " Plug 'vim-pandoc/vim-pandoc-syntax'

  " ==========================================================================
  " Language: Nginx
  " Disabled, rarely used.
  " ==========================================================================

  "Plug 'chr4/nginx.vim'

  " Same as in official upstream, @mhinz tends to update more often
  " @see http://hg.nginx.org/nginx/file/tip/contrib/vim
  " Plug 'mhinz/vim-nginx'
  "Plug 'moskytw/nginx-contrib-vim'

  " ==========================================================================
  " Language: PHP, twig
  " ==========================================================================

  " ----------------------------------------
  " Syntax
  " ----------------------------------------

  " creates twig ft
  "Plug 'evidens/vim-twig'

  " Syntax

  " Neovim comes with
  "   https://jasonwoof.com/gitweb/?p=vim-syntax.git;a=blob;f=php.vim;hb=HEAD
  " 2072 has a fork of an older version but has support for php 5.6 and other
  " changes. It does not support embedded HTML with Neovim
  "Plug '2072/vim-syntax-for-PHP'

  " Updated for php 7.1, Apr 2018 (newer than neovim 3.0 runtime)
  Plug 'StanAngeloff/php.vim', { 'for': [ 'php' ] }

  " Indent
  " 2072 is included with vim, this is upstream
  Plug '2072/PHP-Indenting-for-VIm'

  " Fix indent of HTML in all PHP files -- basically adds indent/html.vim when
  " outside of PHP block.
  " This actually never loads since 2072 sets b:did_indent
  " Also not needed since 2072 uses <script.*> style indenting for HTML
  "Plug 'captbaritone/better-indent-support-for-php-with-html'

  " ==========================================================================
  " Language: Python
  " ==========================================================================

  " Vim's python ftplugin upstream
  " Not a valid plugin runtime structure, file needs to be in ftplugin/
  "Plug 'sullyj3/vim-ftplugin-python'

  "Plug 'lambdalisue/vim-pyenv', { 'for': [ 'python' ] }
  Plug 'Vimjas/vim-python-pep8-indent'

  " ==========================================================================
  " Language: Ruby, rails, puppet
  " ==========================================================================

  " creates pp filetype
  "Plug 'rodjek/vim-puppet'

  " highlighting for Gemfile
  "Plug 'tpope/vim-bundler'

  " creates ruby filetype
  "Plug 'vim-ruby/vim-ruby'

  " ==========================================================================
  " Language: Stylesheets
  " ==========================================================================

  " ----------------------------------------
  " Syntax
  " ----------------------------------------

  " Upstream Neovim uses https://github.com/genoma/vim-less
  "   - more groups
  "   - no conflict with vim-css-color

  "Plug 'groenewege/vim-less'
  " - the syntax file here is actually older than genoma
  " - creates less filetype
  " - Conflicts with vim-css-color

  " 1)  runtime css.vim provides @media syntax highlighting where hail2u
  "     doesn't JulesWang/css.vim was upstream for $VIMRUNTIME up until Vim 8
  "     - Only needed for old vim!!
  " 2)  hail2u extends vim's css highlighting
  "     - Super up-to-date with spec, after syntax that extends runtime
  " 3)  scss-syntax needs the 'for' since it has an ftdetect that doesn't check
  "     if the ft was already set. The result is that without 'for', the
  "     filetype will be set twice successively (and any autocommands will run
  "     twice), particularly in neovim which comes with tpope's (older) scss
  "     rumtimes.
  "     - Extra indent support
  "     - NeoVim comes with tpope's 2010 syntax that pulls in sass.vim and
  "       adds comment matching. sass.vim is okay, but doesn't have as many hi
  "       groups.
  Plug 'JulesWang/css.vim', PlugIf(v:version <= 704)
  Plug 'hail2u/vim-css3-syntax'
  Plug 'cakebaker/scss-syntax.vim', { 'for': [ 'scss' ] }

  " ==========================================================================
  " Color highlighting
  " ==========================================================================
  " The current choice is vim-css-color because it offers stability and
  " completeness. It can do multiple css colors on one line, which hexokinase
  " cannot, and it updates immediately, which coc-highlight has trouble
  " keeping up with.

  Plug 'ap/vim-css-color'
  "Plug 'gu-fan/colorv.vim'    --  requires python
  "Plug 'chrisbra/Colorizer'  --  slower and not as complete but more features
  "                               like X11 colors and color translation for
  "                               degraded terminals
  " use signs or virtualtext to display color
  " let g:Hexokinase_highlighters = [ 'virtual' ]
  " let g:Hexokinase_refreshEvents = [ 'BufEnter', 'BufWinEnter', 'BufWritePost', 'TextChanged', 'TextChangedI' ]
  " let g:Hexokinase_optInPatterns = [ 'full_hex', 'triple_hex', 'rgb', 'rgba', 'colour_names' ]
  " let g:Hexokinase_ftAutoload = [ 'css', 'html', 'javascript', 'javascript.jsx', 'xml' ]
  "Plug 'RRethy/vim-hexokinase'

  " ==========================================================================
  " Language: .tmux.conf
  " ==========================================================================

  " Older syntax but has neat features
  "Plug 'tmux-plugins/vim-tmux'
  " Less feature filled but this is upstream for $VIMRUNTIME and more up-to-date
  Plug 'ericpruitt/tmux.vim', { 'rtp': 'vim/' }

  " ==========================================================================
  " Language: VimL
  " vim-lookup and vim-vimlint replaced by coc-vimlsp
  " ==========================================================================

  Plug 'machakann/vim-vimhelplint'

  Plug 'junegunn/vader.vim'

  " Auto-prefix continuation lines with \
  " Error: <CR> recursive mapping
  " Plug 'lambdalisue/vim-backslash'

  " ==========================================================================
  " Search
  " See after/plugin/search.vim for complex configuration
  " ==========================================================================

  " <Plug> to not move on * search function
  Plug 'haya14busa/vim-asterisk'

  " ==========================================================================
  " UI -- load last!
  " ==========================================================================

  Plug 'delphinus/vim-auto-cursorline'

  " --------------------------------------------------------------------------
  " Quickfix window
  " --------------------------------------------------------------------------

  Plug 'blueyed/vim-qf_resize'

  Plug 'romainl/vim-qf'

  " --------------------------------------------------------------------------
  " Multi sign column
  " --------------------------------------------------------------------------

  " Always show signs column with marks
  "Too many features, slow start
  "Plug 'tomtom/quickfixsigns_vim'
  "Still slowish but better 78ms
  "Plug 'kshenoy/vim-signature'
  " Fastest 91ms
  let g:showmarks_include = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
  let g:showmarks_ignore_type = 'hpq'
  Plug 'bootleq/ShowMarks'

  " --------------------------------------------------------------------------
  " Window events
  " --------------------------------------------------------------------------

  " Disabled, not worth the overhead.
  " Alternatively use sjl/vitality.vim -- but that has some cursor shape stuff
  " that Neovim doesn't need.
  " @see <https://github.com/sjl/vitality.vim/issues/31>
  "Plug 'tmux-plugins/vim-tmux-focus-events'

  Plug 'wellle/visual-split.vim', { 'on': [
        \   'VSResize', 'VSSplit',
        \   'VSSplitAbove', 'VSSplitBelow',
        \   '<Plug>(Visual-Split',
        \ ] }

endfunction
