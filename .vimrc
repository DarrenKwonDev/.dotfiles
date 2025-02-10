" vi non compatible mode. should enable to use vim's improved features
"--------------------------------------------------------------------------
set nocompatible


syntax on
filetype plugin indent on

"debug print out
"echom "[debug] Loading .vimrc..."


" [vim variables]
"--------------------------------------------------------------------------
" use space as <Leader>
let mapleader=" " 


" [tags]
"--------------------------------------------------------------------------
" tags for ctags, path, suffixesadd for gf(go to file), :find
" mostly set by manual cmd by project structure

set tags=tags;/ " recursively searches for 'tags' file from current directory up to root.
" press f5 for generate ctags. should ctags installed get enlisted in $PATH
:nnoremap <f5> :!ctags -R --verbose<CR>

function! ShowFileTags()
    let l:win = bufwinnr('__TagList__')
    if l:win != -1
        noautocmd execute l:win . 'wincmd w'
        return
    endif

    let l:tmpfile = tempname()
    let l:curr_file = expand('%:p')
    
    " ctags 명령어 수정
    execute 'silent !ctags -f - --format=2 --excmd=pattern --fields=+n -R --sort=no --c-kinds=+pe ' . l:curr_file . ' > ' . l:tmpfile
    
    let l:orig_bufnr = bufnr('%')
    noautocmd vertical topleft new __TagList__
    setlocal noreadonly
    setlocal modifiable
    vertical resize 30
    
    " 태그 처리
    let l:tags = []
    let l:current_enum = ''
    let l:enum_members = []
    let l:delayed_tags = []
    
    " 먼저 모든 태그를 읽어서 enum을 찾음
    for line in readfile(l:tmpfile)
        let l:parts = split(line, '\t')
        if len(l:parts) >= 4
            let l:name = l:parts[0]
            let l:kind = l:parts[3][0]
            
            " enum 타입을 먼저 찾아서 저장
            if l:kind ==# 'g'  " enum 정의
                let l:current_enum = l:name
                call add(l:tags, '>E ' . l:name)
            endif
        endif
    endfor
    
    " 다시 파일을 읽어서 나머지 태그들을 처리
    for line in readfile(l:tmpfile)
        let l:parts = split(line, '\t')
        if len(l:parts) >= 4
            let l:name = l:parts[0]
            let l:kind = l:parts[3][0]
            
            if l:kind ==# 'e'  " enum 멤버
                call add(l:tags, '  ├─ ' . l:name)
            elseif l:kind ==# 'f'
                call add(l:delayed_tags, '>F ' . l:name)
            elseif l:kind ==# 'v'
                call add(l:delayed_tags, '>V ' . l:name)
            endif
        endif
    endfor
    
    " 나머지 태그들을 추가
    call extend(l:tags, l:delayed_tags)
    
    " 태그 목록을 버퍼에 삽입
    call setline(1, l:tags)
    
    " 버퍼 설정
    setlocal buftype=nofile
    setlocal bufhidden=delete
    setlocal nobuflisted
    setlocal noswapfile
    setlocal nomodifiable
    setlocal readonly
    
    " 이전 TagList 버퍼 정리
    for buf in range(1, bufnr('$'))
        if buflisted(buf) && bufname(buf) == '__TagList__' && buf != bufnr('%')
            execute 'bdelete! ' . buf
        endif
    endfor
    
    " 키 매핑
    nnoremap <buffer> q :close<CR>
    
    call delete(l:tmpfile)
    redraw!
endfunction

" 태그 목록 열기 단축키
nnoremap <Leader>tl :call ShowFileTags()<CR>

" [path]
"--------------------------------------------------------------------------
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

" [scroll]
"--------------------------------------------------------------------------
" when cursor reach 3/4 of window, window scroll. 
" this option mimicking of vscode default setting. 
let &scrolloff = float2nr(winheight(0) * 0.25)

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

" whole indentation and return prev cursor)
" mz = current cursor save z marker
" gg = go to line number 1
" =G = whole indentation
" `z = turn back to z mark
:nnoremap <Leader>g mzgg=G`z

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
set tabstop=4 
set softtabstop=4

" <, > indent affected by shiftwidth. should same with tabstop, softtabstop
set shiftwidth=4

" [number format]
"--------------------------------------------------------------------------
" vim interpret number decimal not oct (vim < 8.0 default is oct)
" <C-a>, <C-x> affected by this setting.
set nrformats=


" [encoding]
"--------------------------------------------------------------------------
" locale sensitive. but notice that korean stock market use euc-kr
set encoding=utf-8
""set fileencodings=utf-8
""set termencoding=utf-8
""set encoding=euc-kr

" [backspace]
"--------------------------------------------------------------------------
" The backspace key has slightly unintuitive behavior by default. For example,
" by default, you can't backspace before the insertion point set with 'i'.
" This configuration makes backspace behave more reasonably, in that you can
" backspace over anything.
set backspace=indent,eol,start

" Backspace fix for xterm
set t_kb=^H
inoremap <Char-0x07F> <BS>
inoremap <Char-0x0C> <Space>


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
" set noswapfile
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
           let l:bufnum = str2nr(l:match[1])
           if buflisted(l:bufnum)  " check if buffer exists
               call add(l:buffers, l:match[1])
           endif
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
autocmd BufDelete * redraw!
