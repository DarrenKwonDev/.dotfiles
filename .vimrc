" vi non compatible mode. should enable to use vim's improved features
"--------------------------------------------------------------------------
set nocompatible


syntax on
filetype plugin indent on

"debug print out
"echom "[debug] Loading .vimrc..."


" [tags, path]
"--------------------------------------------------------------------------
" tags for ctags, path, suffixesadd for gf(go to file), :find
" mostly set by manual cmd by project structure

set tags=tags;/ " recursively searches for 'tags' file from current directory up to root.

" press f5 for generate ctags. should ctags installed get enlisted in $PATH
:nnoremap <f5> :!ctags -R --verbose<CR>


set path=.,**
set suffixesadd=

function! DetectAndSetupProject()
  " c/c++ project
  if filereadable('Makefile') || filereadable('CMakeLists.txt')
    setlocal path+=/usr/include/**,/usr/local/include/**
    if isdirectory('include')
      setlocal path+=include/**
    endif
    if isdirectory('src/include')
      setlocal path+=src/include/**
    endif
    setlocal suffixesadd+=.h,.c,.hpp,.cpp
  endif

  " node.js proejct
  if filereadable('package.json')
    setlocal path+=src/**,components/**
    setlocal suffixesadd+=.js,.jsx,.ts,.tsx
  endif
  
  " python project
  if filereadable('requirements.txt') || filereadable('setup.py')
    setlocal suffixesadd+=.py
  endif
endfunction

" when open buffer, call DetectAndSetupProject
autocmd BufEnter * call DetectAndSetupProject()

" [cursor shape]
"--------------------------------------------------------------------------
" 2 : block cursor,
" 5 : vertical cursor no blink, 6 : vertical cursor with blink

" insert mode cursor
let &t_SI = "\e[6 q"

" normal mode cursor
let &t_EI = "\e[2 q"

" [editor view related setting]
"--------------------------------------------------------------------------

" absolute number in current cursor line, relative number in other line 
set number relativenumber

" default ruler disable. use statusline
"set ruler 

" 0 : never, 1 : wnd >= 2, 2 : always
set laststatus=2

set statusline=
set statusline+=%#StatusLine#\ [PATH]:\ %F
set statusline+=%#StatusLineNC#\ [LOC]\ %l:%c            " row:col
set statusline+=%#StatusLineNC#\ [%p%%]         " pos percent 
set statusline+=%=                              " for right align
set statusline+=%#StatusLine#\ [%t]             " file name
set statusline+=%#StatusLineNC#\ [%{&filetype}]
set statusline+=%#StatusLineNC#\ [%{&fileformat}]
set statusline+=%#StatusLine#\ [%{&fileencoding?&fileencoding:&encoding}]


" {, [, ( is default, add <:> for html
set showmatch
set matchpairs+=<:>

" auto close bracket
inoremap { {}<Left>
inoremap ( ()<Left>
inoremap [ []<Left>
inoremap " ""<Left>
inoremap ' ''<Left>


set cursorline
" set cursorcolumn

" show long line into one line. no line break
set nowrap

" [indent, code align]
"--------------------------------------------------------------------------
set cindent
set autoindent
set smartindent

:nnoremap Q gq

set textwidth=80
"set formatoptions+=tcqj


" [search]
"--------------------------------------------------------------------------
" Enable searching as you type, rather than waiting till you press enter.
set incsearch

" [highlight]
"--------------------------------------------------------------------------
" highlight search result
set hlsearch

" highlight current word
augroup highlight_current_word
    autocmd!
    autocmd CursorMoved * exe printf('match IncSearch /\V\<%s\>/', escape(expand('<cword>'), '/\'))
augroup END


" [tab]
"--------------------------------------------------------------------------

" use space when tab pressed
set expandtab

" should tabstop, softtabstop value same to avoid confusion
set tabstop=2 
set softtabstop=2 

" <, > indent affected by shiftwidth. should same with tabstop, softtabstop
set shiftwidth=2

" [number format]
"--------------------------------------------------------------------------
" vim interpret number decimal not oct (vim < 8.0 default is oct)
" <C-a>, <C-x> affected by this setting.
set nrformats=


" [encoding]
"--------------------------------------------------------------------------
" locale sensitive. but notice that korean stock market use euc-kr
set encoding=utf-8
set fileencodings=utf-8
set termencoding=utf-8


" [backspace]
"--------------------------------------------------------------------------
" The backspace key has slightly unintuitive behavior by default. For example,
" by default, you can't backspace before the insertion point set with 'i'.
" This configuration makes backspace behave more reasonably, in that you can
" backspace over anything.
set backspace=indent,eol,start


" [hidden]
"--------------------------------------------------------------------------
" By default, Vim doesn't let you hide a buffer (i.e. have a buffer that isn't
" shown in any window) that has unsaved changes. This is to prevent you from "
" forgetting about unsaved changes and then quitting e.g. via `:qa!`. We find
" hidden buffers helpful enough to disable this protection. See `:help hidden`
" for more information on this.
set hidden

" [case]
"--------------------------------------------------------------------------
" This setting makes search case-insensitive when all characters in the string
" being searched are lowercase. However, the search becomes case-sensitive if
" it contains any capital letters. This makes searching more convenient.

set ignorecase

" smartcase enabled when ignorecase is setted.
set smartcase 


" [mouse]
"--------------------------------------------------------------------------
" Enable searching as you type, rather than waiting till you press enter.
" Enable mouse support. You should avoid relying on this too much, but it can
" sometimes be convenient.
set mouse=r


" [etc]
"--------------------------------------------------------------------------
set visualbell
set nobackup
set noswapfile
set history=1000



" [settings]
"--------------------------------------------------------------------------
" press %% in cmd mode, show current buffer's path
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'


" [tabline (buffer list)]
"--------------------------------------------------------------------------
set showtabline=2   "always show tabline

" 0 is black, 7 is lightgray, 8 is darkgray
hi TabLineFill term=NONE cterm=NONE
hi TabLine term=NONE cterm=NONE ctermfg=7 ctermbg=8
hi TabLineSel term=bold cterm=bold ctermfg=0 ctermbg=7

function! BufferTabLine()
  let s = ''
  " save current buffer number
  let current = bufnr('%')
  
  " use ls! cmd to check all buffer list
  let l:buffers = []
  let l:bufnames = execute('ls!')
  for l:line in split(l:bufnames, "\n")
    let l:match = matchlist(l:line, '\v\s*(\d+)[^"]*"([^"]*)"')
    if !empty(l:match)
      call add(l:buffers, l:match[1])
    endif
  endfor
  
  for l:bufnum in l:buffers
    let i = str2nr(l:bufnum)
    " current buffer highlight
    if i == current
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif
    
    let s .= ' ' . i . ':'
    
    " modified buffer show *
    if getbufvar(i, "&modified")
      let s .= '* '
    endif
    
    let bufname = bufname(i)
    let fname = fnamemodify(bufname, ':t')
    if fname == ''
      let s .= '[No Name]'
    else
      let s .= strlen(fname) > 20 ? fname[0:17] . '...' : fname
    endif
    
    let s .= ' '
  endfor
  
  let s .= '%#TabLineFill#'
  return s
endfunction

set tabline=%!BufferTabLine()
