filetype off
syntax on

let base16colorspace=16
let g:solarized_termcolors=16

if filereadable(expand("~/.vimrc_background"))
    source ~/.vimrc_background
endif

let g:solarized_termtrans=1
let g:mapleader = ","
let mapleader = ","
let g:ycm_confirm_extra_conf = 0
let g:clang_format#command="clang-format-3.6"
let g:clang_format#detect_style_file=1
let g:clang_format#auto_formatexpr=1
let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'
let g:ctrlp_switch_buffer = 0
let g:ctrlp_dotfiles = 0
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_match_window_bottom = 0
let g:ctrlp_match_window_reversed = 0
set textwidth=0

set ai
set autoread
set background=dark
set backspace=indent,eol,start
set clipboard=unnamed
set cmdheight=1
set colorcolumn=120
set cursorline
set encoding=utf-8 nobomb
set esckeys
set expandtab
set exrc
set ffs=unix,mac,dos
set ff=unix
set gdefault
set history=700
set hlsearch
set ignorecase
set incsearch
set laststatus=2
set lazyredraw
set magic
set mat=2
set modeline
set nobackup
set nocompatible
set noerrorbells
set nohidden
set noswapfile
set novisualbell
set nowb
set number
set ruler
set secure
set shell=/bin/bash
set shiftwidth=4
set shortmess=atI
set showcmd
set showmatch
set showmode
set si
set smartcase
set splitright
set splitbelow
set softtabstop=4
set t_Co=256
set t_vb=
set tabpagemax=50
set tabstop=4
set title
set tm=500
set ttyfast
set whichwrap+=<,>,h,l
set wildignore=*.o,*~,*.pyc,*/build/*,*/bin/*
set wildmenu

hi TabLine ctermfg=10

try
  set switchbuf=useopen,usetab,newtab
  set stal=2
catch
endtry

nnoremap <C-J> <C-A-Up>
nnoremap <C-K> <C-A-Down>
nnoremap <C-H> <C-A-Left>
nnoremap <C-L> <C-A-Right>
nmap <F1> :if expand('%:e')=='hh'<CR>e %:r.cc<CR>else<CR>e %:r.hh<CR>endif<CR><CR>
:imap jj <Esc>
:imap qq <Esc>
:imap `` <Esc>

noremap <F3> :Autoformat<CR>
noreabbrev cav cd ~/src/av
noreabbrev ccd cd %:p:h
noreabbrev ccdd cd %:p:h <bar> cd ..
noreabbrev setgopath let $GOPATH='.'

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" Plugin 'Valloric/YouCompleteMe'
" Plugin 'rdnetto/YCM-Generator'
" Plugin 'rhysd/vim-clang-format'
Plugin 'Chiel92/vim-autoformat'
"Plugin 'honza/vim-snippets'
Bundle 'edkolev/tmuxline.vim'
"Plugin 'Shougo/vimproc.vim'
Plugin 'VundleVim/Vundle.vim'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'bronson/vim-trailing-whitespace'
Plugin 'chriskempson/base16-vim'
"Plugin 'davidhalter/jedi-vim'  " CPU issues
Plugin 'fatih/vim-go'
"Plugin 'kien/ctrlp.vim'
Plugin 'nvie/vim-flake8'
"Plugin 'pangloss/vim-javascript'
"Plugin 'peplin/vim-phabrowse'
Plugin 'scrooloose/nerdtree'
"Plugin 'scrooloose/syntastic'
"Plugin 'sjl/gundo.vim'
"Plugin 'ssh://code@code.int.uberatc.com/diffusion/VIMHIDL/vim-hidl-ftplugin.git'
Plugin 'stephpy/vim-yaml'
"Plugin 'terryma/vim-multiple-cursors'
"Plugin 'tpope/vim-fugitive'
"Plugin 'tpope/vim-surround'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
"Plugin 'bogado/file-line'
Plugin 'nsf/gocode', {'rtp': 'vim/'}
call vundle#end()

colorscheme base16-ocean

let g:flake8_show_quickfix=1
let g:flake8_show_in_gutter=1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline_theme='base16'
let g:NERDTreeMapOpenInTab = ''
let g:phabrowse_domains = ['https://code.int.uberatc.com']

let g:tmuxline_separators = {
    \ 'left' : '',
    \ 'left_alt': '>',
    \ 'right' : '',
    \ 'right_alt' : '<',
    \ 'space' : ' '}

if has("autocmd")
    filetype on
    filetype plugin on
    filetype indent on

    autocmd StdinReadPre * let s:std_in=1
    autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
    autocmd BufNewFile,BufRead *.json setfiletype json setlocal syntax=javascript ts=2 sts=2
    autocmd BufNewFile,BufRead *.md setfiletype markdown
    autocmd BufNewFile,BufRead *.yml,*.sls setfiletype yaml
    autocmd BufNewFile,BufRead *.hidl setfiletype cpp
    autocmd BufNewFile,BufRead *.go setlocal syntax=go
    autocmd BufNewFile,BufRead Vagrantfile setfiletype ruby
    autocmd BufNewFile,BufRead BUILD.* setfiletype conf setlocal syntax=conf
    autocmd BufNewFile,BufRead *.bzl setfiletype py setlocal syntax=python
    autocmd BufNewFile,BufRead *.py set ts=4 sts=4 sw=4 expandtab nosmartindent ff=unix
    autocmd BufWritePost *.py call Flake8()
    " autocmd BufNewFile,BufRead *.yaml,*.yml so ~/.vim/bundle/vim-yaml/after/yaml.vim
    " autocmd Filetype c,cpp,hidl set comments^=:///

    autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab smartindent
    autocmd FileType sh setlocal ts=2 sts=2 sw=2 expandtab smartindent

    " autocmd BufWritePre *.go call go#lint#Run()
endif

function! NumberToggle()
    if(&rnu == 1)
        set nu
        set nornu
    else
        set nonu
        set rnu
    endif
endfunc

nnoremap <C-n> :call NumberToggle()<cr>

"if has("autocmd")
"    filetype on
"    filetype plugin on
"    filetype indent on
"
"    " autocmd FileType javascript setlocal ts=2 sts=2 sw=2
"    " autocmd FileType json setlocal ts=2 sts=2 sw=2
"    " autocmd FileType ruby setlocal ts=2 sts=2 sw=2
"    " autocmd FileType yaml setlocal ts=2 sts=2 sw=2
"
"    autocmd BufReadPost *
"        \ if line("'\"") > 0 && line("'\"") <= line("$") |
"        \   exe "normal! g`\"" |
"        \ endif
"endif

highlight LineNr ctermbg=0
highlight colorcolumn ctermbg=0

