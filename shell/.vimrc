" ~/.vimrc — plugin-free vim for hosts without nvim.
" Keymaps mirror the nvim config so muscle memory carries over.

set nocompatible
syntax on
filetype plugin indent on
set t_Co=256
set background=dark

set number relativenumber cursorline signcolumn=yes
set tabstop=2 shiftwidth=2 expandtab autoindent
set nowrap scrolloff=8
set ignorecase smartcase incsearch hlsearch
set splitright splitbelow
set backspace=indent,eol,start
set hidden noswapfile
set wildmenu wildmode=longest:full,full
set laststatus=2 showcmd
set mouse=a
set ttimeoutlen=10

" Persistent undo
if has('persistent_undo')
  silent! call mkdir(expand('~/.vim/undo'), 'p', 0700)
  set undodir=~/.vim/undo undofile
endif

let mapleader = " "
inoremap jk <Esc>
nnoremap <leader>nh :nohl<CR>
nnoremap <leader>+ <C-a>
nnoremap <leader>- <C-x>

" splits
nnoremap <leader>sv <C-w>v
nnoremap <leader>sh <C-w>s
nnoremap <leader>se <C-w>=
nnoremap <leader>sx :close<CR>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" tabs
nnoremap <leader>to :tabnew<CR>
nnoremap <leader>tx :tabclose<CR>
nnoremap <leader>tn :tabn<CR>
nnoremap <leader>tp :tabp<CR>

" netrw as the file tree
let g:netrw_liststyle = 3
let g:netrw_banner = 0
let g:netrw_winsize = 25
nnoremap <leader>ee :Lexplore<CR>
