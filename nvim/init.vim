" echomsg "Start of the init file..."

" LEGACY
" ======

" Enable filetype events (though note that this is on by default in Neovim)
filetype indent plugin on

" Use Vim settings, rather then Vi settings (much better!).
" This must be done early, because it changes other options as a side effect.
set nocompatible

" -----

" Standardise on UTF-8 and unix line endings where possible
setlocal encoding=utf-8
setlocal fileencodings=utf-8,ucs-bom
setlocal fileformats=unix,dos

" Enable line numbers
setlocal number

" Visual bell only because noises suck
setlocal visualbell

" Autocommand triggers
" --------------------

" And associated functions...

" Filetype-specific logic
function! SetFileTypeOptions()
    let t=&filetype
    let sourcetypes=['vim', 'python', 'c', 'cpp', 'sh', 'php', 'yaml', 'css', 'javascript', 'scss', 'html', 'htmldjango', 'apache', 'samba']
    let sourcetwospaces=['yaml', 'php', 'html', 'htmldjango']
    if index(sourcetypes, t) >= 0
        let s:indentwidth=4
        if index(sourcetwospaces, t) >= 0
            let s:indentwidth=2
        endif
        
        let &l:shiftwidth=s:indentwidth
        let &l:tabstop=s:indentwidth

        setlocal expandtab
        setlocal autoindent

        setlocal textwidth=0
    endif
endfunction

" Stop vim behaving badly on very large files
function! LargeFileCheck()
    " For personal reference:
    "   eventignore+=FileType (no syntax highlighting etc assumes FileType always on)
    "   noswapfile (save copy of file)
    "   bufhidden=unload (save memory when other file is viewed)
    "   buftype=nowritefile (is read-only)
    "   undolevels=-1 (no undo possible)
    let s:f=expand("<afile>")
    let LargeFileThreshold=100*1024*1204
    if getfsize(s:f) > LargeFileThreshold
        setlocal eventignore+=FileType
        setlocal noswapfile bufhidden=unload buftype=nowrite undolevels=-1
    else
        setlocal eventignore-=FileType
    endif
endfunction

augroup mine
    autocmd!
    autocmd BufReadPre * call LargeFileCheck()
    autocmd FileType * call SetFileTypeOptions()
augroup END

" Feature tests
" -------------

if has("mouse")
    set mouse=a
endif

if has("win32")
    " echomsg "WIN32"
    source $VIMRUNTIME/mswin.vim
endif

" Keybinds
" --------

" Key to view which syntax group is currently under the cursor (useful for
" debugging color schemes etc.)
map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
    \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
    \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

set termguicolors
colorscheme molokayo
