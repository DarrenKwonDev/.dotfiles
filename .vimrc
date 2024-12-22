syntax on
filetype plugin indent on

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

" statusline
set statusline=
set statusline+=%#StatusLine#\ %l:%c            " 행:열
set statusline+=%#StatusLineNC#\ [%p%%]         " 위치 퍼센트
set statusline+=%=                              " 오른쪽 정렬
set statusline+=%#StatusLine#\ %y               " 파일 타입
set statusline+=%#StatusLineNC#\ [%{&fileformat}] " 파일 포맷
set statusline+=%#StatusLine#\ [%{&fileencoding?&fileencoding:&encoding}] " 인코딩



" {, [, ( 
set showmatch

set cursorline
" set cursorcolumn


" [indent]
"--------------------------------------------------------------------------
set cindent
set autoindent
set smartindent


" [search]
"--------------------------------------------------------------------------
" Enable searching as you type, rather than waiting till you press enter.
set incsearch

" highlight
set hlsearch

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

" vi non compatible mode. should enable to use vim's improved features
set nocompatible
