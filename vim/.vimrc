" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  " set backup		" keep a backup file
endif
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
" map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

fun! MatchOverlength()
	if exists('g:longLinesHighlighted')
		unlet g:longLinesHighlighted
		match 
	else
		let g:longLinesHighlighted=1
		match ErrorMsg '\%>80v.\+'
	endif
endfun

map <C-U> :call MatchOverlength()<CR>

" MacVim settings
if has("gui_macvim")
    colorscheme molokai

    set guifont=Menlo:h15
    set lines=70
    set columns=140
endif

" Remove menu bar, toolbar and 'tear-off' menus under win32
if has("gui_gtk") || has("gui_win32")
	set guioptions-=T
	set guioptions-=m
	set guioptions-=t
endif

" Use alt-space simulation to maximize window for win32
if has("gui_win32")
    source $VIMRUNTIME/mswin.vim
    behave mswin
	
	" set gfn=Monaco:h10
	" set gfn=DejaVu\ Sans\ Mono:h11
    set gfn=Consolas:h11

    if hostname()=="CHRISLAPTOP"
        colorscheme solarized
        " set background=light
    else
        colorscheme solarized
        set background=dark
    endif

	au GuiEnter * simalt ~x
endif

if !has("gui_running")
    set background=dark
endif

set visualbell


function! ApplySourceFiletypeOptions()
	let t=&filetype
    let sourcetypes=['vim', 'python', 'c', 'cpp', 'sh', 'php', 'yaml', 'css', 'javascript', 'scss', 'html', 'htmldjango']
    let two_spaces=['yaml', 'php', 'html', 'htmldjango']
    if index(sourcetypes, t) >= 0
		set expandtab
        set number
        set autoindent
        if index(two_spaces, t) >= 0
            set shiftwidth=2
            set tabstop=2
        else
            set shiftwidth=4
            set tabstop=4
        endif
	endif
endfunction

" General settings for all source code filetypes
autocmd FileType * call ApplySourceFiletypeOptions()

autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType gitcommit setlocal textwidth&

function! LargeFileCheck()
	" eventignore+=FileType (no syntax highlighting etc assumes FileType always on)
	" noswapfile (save copy of file)
	" bufhidden=unload (save memory when other file is viewed)
	" buftype=nowritefile (is read-only)
	" undolevels=-1 (no undo possible)
	let f=expand("<afile>")
	let LargeFileThreshold=100*1024*1204
	if getfsize(f) > LargeFileThreshold
		set eventignore+=FileType
		setlocal noswapfile bufhidden=unload buftype=nowrite undolevels=-1
	else
		set eventignore-=FileType
	endif
endfunction

autocmd BufReadPre * :call LargeFileCheck()

function! ReplaceDots()
    :%s/^•/1./g
endfunction

function! CleanChars()
    :%s/–/-/g
    :%s/’/'/g
endfunction

" PLUGIN SETTINGS
" ===============

if hostname() == "CHRISLAPTOP"
    " Path for taglist so that it can find ctags
    let Tlist_Ctags_Cmd=$HOME.'\ctags.exe'
    map <F4> :TlistToggle<cr>
    map <F8> :!C:\Users\Dav\ctags.exe -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>
endif

map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

set encoding=utf-8
set fileencodings=utf-8,ucs-bom
set fileformats=unix,dos
