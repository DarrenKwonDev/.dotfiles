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


" ===== Tag list settings =====
let g:reserved_keywords = [
            \ 'if', 'else', 'while', 'do', 'for', 'switch', 'case', 'break',
            \ 'continue', 'return', 'goto', 'sizeof', 'typedef',
            \ 'void', 'char', 'short', 'int', 'long', 'float', 'double',
            \ 'signed', 'unsigned', 'const', 'volatile', 'register', 'static', 'extern',
            \ 'struct', 'union', 'enum', 'class', 'namespace', 'template', 'typename',
            \
            \ 'def', 'class', 'lambda', 'try', 'except', 'finally', 'raise',
            \ 'import', 'from', 'as', 'pass', 'with', 'assert', 'yield',
            \ 'global', 'nonlocal', 'and', 'or', 'not', 'is', 'in', 'None',
            \ 'True', 'False', 'del', 'async', 'await',
            \
            \ 'func', 'package', 'import', 'type', 'interface', 'map', 'chan',
            \ 'go', 'select', 'defer', 'fallthrough', 'range', 'var', 'iota',
            \ 'nil', 'make', 'new', 'len', 'cap', 'panic', 'recover',
            \
            \ 'if', 'else', 'for', 'while', 'return', 'break', 'continue',
            \ 'switch', 'case', 'default', 'true', 'false', 'null'
            \ ]


" [tags]
"--------------------------------------------------------------------------
" tags for ctags, path, suffixesadd for gf(go to file), :find
" mostly set by manual cmd by project structure

set tags=tags;/ " recursively searches for 'tags' file from current directory up to root.
" press f5 for generate ctags. should ctags installed get enlisted in $PATH
:nnoremap <f5> :!ctags -R --verbose<CR>

function! ShowFileTags()
    " Prevent opening new buffer in TagList buffer
    if bufname('%') ==# '__TagList__'
        return
    endif

    " Close existing TagList window if exists
    let l:existing_win = bufwinnr('__TagList__')
    if l:existing_win != -1
        execute l:existing_win . 'wincmd c'
    endif

    let l:tmpfile = tempname()
    let l:curr_file = expand('%:p')

    " Run ctags with all necessary fields
    let l:ctags_cmd = 'ctags -f - --format=2 --excmd=pattern --fields=+nks -R --sort=no --c-kinds=+pesdmvx '
    let l:ctags_result = system(l:ctags_cmd . shellescape(l:curr_file))

    " Check if ctags command failed
    if v:shell_error
        echohl ErrorMsg
        echo "Error running ctags command"
        echohl None
        return
    endif


    let l:filtered_result = []
    for line in split(l:ctags_result, '\n')
        let l:parts = split(line, '\t')
        if len(l:parts) >= 1 && l:parts[0] !~ '^anon'
            call add(l:filtered_result, line)
        endif
    endfor


    call writefile(split(l:ctags_result, '\n'), l:tmpfile)

    let l:orig_bufnr = bufnr('%')
    noautocmd vertical topleft new __TagList__
    setlocal noreadonly
    setlocal modifiable
    vertical resize 30

    let l:tags = []

    " === Section 1: Macros ===
    let l:macros = []
    call add(l:tags, '=== Macros ===')
    for line in readfile(l:tmpfile)
        let l:parts = split(line, '\t')
        if len(l:parts) >= 4 && l:parts[3][0] ==# 'd'
            call add(l:macros, '>M ' . l:parts[0])
        endif
    endfor
    call extend(l:tags, sort(l:macros))

    " === Section 2: Structs ===
    call add(l:tags, '')
    call add(l:tags, '=== Structures ===')
    let l:structs = {}
    for line in readfile(l:tmpfile)
        let l:parts = split(line, '\t')
        if len(l:parts) >= 4
            let l:name = l:parts[0]
            let l:kind = l:parts[3][0]

            if l:kind ==# 's'
                let l:structs[l:name] = []
            elseif l:kind ==# 'm'
                let l:scope = ''
                for field in l:parts[3:]
                    if field =~ '^struct:'
                        let l:scope = substitute(field, '^struct:', '', '')
                        break
                    endif
                endfor
                if has_key(l:structs, l:scope)
                    call add(l:structs[l:scope], l:name)
                endif
            endif
        endif
    endfor

    for struct_name in sort(keys(l:structs))
        call add(l:tags, '>S ' . struct_name)
        let l:members = sort(l:structs[struct_name])
        let l:last_idx = len(l:members) - 1
        for idx in range(len(l:members))
            if idx == l:last_idx
                call add(l:tags, '  └─ ' . l:members[idx])
            else
                call add(l:tags, '  ├─ ' . l:members[idx])
            endif
        endfor
    endfor

    " === Section 3: Enums ===
    call add(l:tags, '')
    call add(l:tags, '=== Enums ===')
    let l:enums = {}
    for line in readfile(l:tmpfile)
        let l:parts = split(line, '\t')
        if len(l:parts) >= 4
            let l:name = l:parts[0]
            let l:kind = l:parts[3][0]

            if l:kind ==# 'g'
                let l:enums[l:name] = []
            elseif l:kind ==# 'e'
                let l:scope = ''
                for field in l:parts[3:]
                    if field =~ '^enum:'
                        let l:scope = substitute(field, '^enum:', '', '')
                        break
                    endif
                endfor
                if has_key(l:enums, l:scope)
                    call add(l:enums[l:scope], l:name)
                endif
            endif
        endif
    endfor

    for enum_name in sort(keys(l:enums))
        call add(l:tags, '>E ' . enum_name)
        let l:members = sort(l:enums[enum_name])
        let l:last_idx = len(l:members) - 1
        for idx in range(len(l:members))
            if idx == l:last_idx
                call add(l:tags, '  └─ ' . l:members[idx])
            else
                call add(l:tags, '  ├─ ' . l:members[idx])
            endif
        endfor
    endfor

    " === Section 4: Functions ===
    let l:functions = []
    call add(l:tags, '')
    call add(l:tags, '=== Functions ===')
    for line in readfile(l:tmpfile)
        let l:parts = split(line, '\t')
        if len(l:parts) >= 4 && l:parts[3][0] ==# 'f'
            call add(l:functions, '>F ' . l:parts[0])
        endif
    endfor
    call extend(l:tags, sort(l:functions))

    " === Section 5: Variables (at the bottom) ===
    let l:variables = []
    call add(l:tags, '')
    call add(l:tags, '=== Variables ===')
    for line in readfile(l:tmpfile)
        let l:parts = split(line, '\t')
        if len(l:parts) >= 4
            let l:kind = l:parts[3][0]
            if l:kind ==# 'v' || l:kind ==# 'x'  " local or external variables
                call add(l:variables, '>V ' . l:parts[0])
            endif
        endif
    endfor
    call extend(l:tags, sort(l:variables))

    " === Section 6: External Calls ===
    let l:function_calls = []
    call add(l:tags, '')
    call add(l:tags, '=== External Calls ===')

    " Parse the current buffer for function calls
    let l:buffer_content = getbufline(l:orig_bufnr, 1, '$')
    let l:seen_calls = {}

    for line in l:buffer_content
        " Match function calls: word followed by opening parenthesis
        let l:matches = matchlist(line, '\(\w\+\)\s*(')
        if !empty(l:matches)
            let l:func_name = l:matches[1]
            " Skip if we've seen this call before, if it's in tags, or if it's a reserved keyword
            if !has_key(l:seen_calls, l:func_name) && 
                        \ index(l:functions, '>F ' . l:func_name) == -1 && 
                        \ index(l:macros, '>M ' . l:func_name) == -1 &&
                        \ index(g:reserved_keywords, l:func_name) == -1
                let l:seen_calls[l:func_name] = 1
                call add(l:function_calls, '>X ' . l:func_name)
            endif
        endif
    endfor

    call extend(l:tags, sort(l:function_calls))

    " Insert tag list into buffer
    call setline(1, l:tags)

    " Buffer settings
    setlocal buftype=nofile
    setlocal bufhidden=delete
    setlocal nobuflisted
    setlocal noswapfile
    setlocal nomodifiable
    setlocal readonly

    " Key mapping
    nnoremap <buffer> q :close<CR>

    " Clean up
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
""set encoding=utf-8
""set fileencodings=utf-8
""set termencoding=utf-8
set encoding=euc-kr

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
fixdel

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
" set noswapfile " 동시 편집하는 경우가 많아서 swp은 반드시 존재해야 한다.
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
