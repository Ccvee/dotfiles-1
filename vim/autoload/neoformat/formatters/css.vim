" autoload/neoformat/formatters/css.vim

function! neoformat#formatters#css#dkoprettier() abort
  let l:config = neoformat#formatters#javascript#dkoprettier()
  let l:config.args += [ '--parser', 'css' ]
  return l:config
endfunction
