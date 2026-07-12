" Enable Spell check
set spell

" Set spell language
set spelllang=en_us

" Disable compatibility with vi which can cause unexpected issues.
set nocompatible

" Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype on

" Enable plugins and load plugin for the detected file type.
filetype plugin on

" Load an indent file for the detected file type.
filetype indent on

" Turn syntax highlighting on.
syntax on

" Add numbers to each line on the left-hand side.
set number

" Highlight cursor line underneath the cursor horizontally.
" set cursorline

" Highlight cursor line underneath the cursor vertically.
" set cursorcolumn

" Set shift width to 4 spaces.
set shiftwidth=4

" Set tab width to 4 columns.
set tabstop=4

" Use space characters instead of tabs.
set expandtab

" Do not save backup files.
set nobackup

" Do not wrap lines. Allow long lines to extend as far as the line goes.
set nowrap

" While searching though a file incrementally highlight matching characters as you type.
set incsearch

" Ignore capital letters during search.
set ignorecase

" Show partial command you type in the last line of the screen.
set showcmd

" Show matching words during a search.
set showmatch

" Set the commands to save in history default number is 20.
set history=1000

" Use highlighting when doing a search.
set hlsearch

" Show the mode you are on the last line.
set showmode

" Override the ignorecase option if searching for capital letters.
" This will allow you to search specifically for capital letters.
set smartcase

" Enable auto completion menu after pressing TAB.
set wildmenu

" Make wildmenu behave like similar to Bash completion.
set wildmode=list:longest

" There are certain files that we would never want to edit with Vim.
" Wildmenu will ignore files with these extensions.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

" ————— core vimrc acima —————
syntax on
colorscheme desert

" truecolor
if has('termguicolors')
  set termguicolors
endif

" custom highlight (adjust 238/239 to whatever looks best for you)
highlight Visual    cterm=NONE ctermfg=NONE ctermbg=238
highlight Search    cterm=NONE ctermfg=NONE ctermbg=239
highlight IncSearch cterm=NONE ctermfg=NONE ctermbg=242
