syntax on
filetype plugin indent on

set nocompatible
set tabstop=2
set shiftwidth=2
set expandtab
set softtabstop=2
set visualbell
set nobackup
set cindent
set autoindent
set smartindent
set enc=euc-kr
set incsearch
set history=1000
set hlsearch
set ignorecase
set showmatch
set number
set ruler 


" locale sensitive
set encoding=utf-8
set fileencodings=utf-8,euc-kr
set termencoding=utf-8


" The backspace key has slightly unintuitive behavior by default. For example,
" by default, you can't backspace before the insertion point set with 'i'.
" This configuration makes backspace behave more reasonably, in that you can
" backspace over anything.
set backspace=indent,eol,start

" By default, Vim doesn't let you hide a buffer (i.e. have a buffer that isn't
" shown in any window) that has unsaved changes. This is to prevent you from "
" forgetting about unsaved changes and then quitting e.g. via `:qa!`. We find
" hidden buffers helpful enough to disable this protection. See `:help hidden`
" for more information on this.
set hidden

" This setting makes search case-insensitive when all characters in the string
" being searched are lowercase. However, the search becomes case-sensitive if
" it contains any capital letters. This makes searching more convenient.
set ignorecase
set smartcase

" Enable searching as you type, rather than waiting till you press enter.
set incsearch
" Enable mouse support. You should avoid relying on this too much, but it can
" sometimes be convenient.
set mouse=r
