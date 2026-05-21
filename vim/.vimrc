" ~/.vimrc - Vim configuration for DevOps/SysAdmin
" ============================================

" ============================================
" Basic settings
" ============================================
set nocompatible              " Use Vim defaults
set number                    " Show line numbers
set relativenumber            " Relative line numbers
set cursorline                " Highlight current line
set cursorcolumn              " Highlight current column

" Indentation
set tabstop=4                 " Tabs are 4 spaces
set shiftwidth=4              " Indent is 4 spaces
set softtabstop=4             " Backspace deletes 4 spaces
set expandtab                 " Use spaces instead of tabs
set autoindent                " Auto indent
set smartindent               " Smart indent

" Search
set hlsearch                  " Highlight search results
set incsearch                 " Incremental search
set ignorecase                " Case insensitive search
set smartcase                 " Case sensitive if uppercase present

" Display
set showmode                  " Show current mode
set showcmd                   " Show command in status line
set wildmenu                  " Command line completion
set wildmode=longest,list     " Completion style
set laststatus=2              " Always show status line
set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P

" Behavior
set backspace=indent,eol,start  " Backspace behavior
set history=1000              " Command history
set undolevels=1000           " Undo levels
set hidden                    " Hide buffers when abandoned
set nowrap                    " Don't wrap lines
set scrolloff=5               " Keep 5 lines around cursor

" Encoding
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,latin1

" ============================================
" Plugin management (vim-plug)
" ============================================
call plug#begin('~/.vim/plugged')

" File navigation
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf.vim'

" Git integration
Plug 'tpope/vim-fugitive'

" Syntax & highlighting
Plug 'sheerun/vim-polyglot'
Plug 'fatih/vim-go'

" Utility
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'

call plug#end()

" ============================================
" Plugin configurations
" ============================================

" NERDTree
let g:NERDTreeShowHidden = 1
let g:NERDTreeMinimalUI = 1
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" FZF
let g:fzf_layout = { 'down': '~40%' }

" ============================================
" Key mappings
" ============================================

" Leader key
let mapleader = ","

" NERDTree toggle
map <leader>n :NERDTreeToggle<CR>

" Easy save and quit
map <leader>w :w<CR>
map <leader>q :q<CR>

" Search and replace in current file
map <leader>s :%s/

" Clear search highlight
map <leader>h :nohlsearch<CR>

" Copy to system clipboard
vmap <leader>y "+y
nmap <leader>Y "+y

" Paste from system clipboard
nmap <leader>p "+p

" Quick edit and reload vimrc
map <leader>ev :vsplit $MYVIMRC<CR>
map <leader>sv :source $MYVIMRC<CR>

" Move lines up/down
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" ============================================
" File type specific settings
" ============================================

" YAML
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" JSON
autocmd FileType json setlocal ts=2 sts=2 sw=2 expandtab

" Dockerfile
autocmd FileType dockerfile setlocal ts=2 sts=2 sw=2 expandtab

" Terraform
autocmd FileType terraform,hcl setlocal ts=2 sts=2 sw=2 expandtab

" Python
autocmd FileType python setlocal ts=4 sts=4 sw=4 expandtab

" Shell
autocmd FileType sh setlocal ts=4 sts=4 sw=4 expandtab

" ============================================
" Auto commands
" ============================================

" Remove trailing whitespace on save
autocmd BufWritePre * %s/\s\+$//e

" Auto reload file if changed outside vim
autocmd FocusGained,BufEnter * checktime

" ============================================
" Colors
" ============================================
syntax enable
set background=dark
colorscheme desert
