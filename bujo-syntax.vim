" Vim syntax file
" Language:     Bullet Journal
" Maintainer:   Adam Vander Pas
" Filenames:    *.bujo
" Last Change:  28 October 2020

if exists("b:current_syntax")
  finish
endif

syn match bujoTodone "^\s*\[x\] .*$"
syn match bujoTodo "^\s*\[\] .*$"
syn match bujoPriorityTodo "^\s*\[\*\] .*$"
syn match bujoEvent "^\s*o .*$"
syn match bujoNote "^\s*\(-\|\d*\.\) .*$"
syn match bujoReject "^\s*\~ .*$"
syn match bujoHyperlink "\[\[http\S\+\]\]" conceal cchar=H

let b:current_syntax = "bujo"

hi def link bujoPriorityTodo Todo
hi def link bujoNote         Type
hi def link bujoTodo         Statement
hi def link bujoEvent        Constant
hi def link bujoTodone       Comment
hi def Strikeout ctermbg=darkblue ctermfg=black guibg=darkblue guifg=blue
hi def link bujoUnderline Type
hi bujoUnderline term=underline,bold cterm=underline,bold gui=underline,bold
hi link bujoReject Strikeout
hi link bujoHyperlink bujoUnderline
