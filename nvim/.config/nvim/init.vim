let mapleader = ' '

call plug#begin('~/.config/nvim/plugged')

Plug 'bling/vim-airline'
Plug 'tpope/vim-commentary'
Plug 'junegunn/goyo.vim'
Plug 'ghifarit53/tokyonight-vim'
Plug 'mhinz/vim-startify'
Plug 'liuchengxu/vim-which-key'
Plug 'lervag/vimtex'
Plug 'SirVer/ultisnips'
Plug 'neovimhaskell/haskell-vim'
Plug 'chrisbra/Colorizer'

call plug#end()
call which_key#register('<Space>', "g:which_key_map")

""" Colors
if has('termguicolors') | set termguicolors | endif
let g:tokyonight_style = 'night'
let g:tokyonight_transparent_background = 1
colorscheme tokyonight
highlight! Normal      ctermbg=NONE guibg=NONE
highlight! NonText     ctermbg=NONE guibg=NONE
highlight! EndOfBuffer ctermbg=NONE guibg=NONE
highlight! SignColumn  ctermbg=NONE guibg=NONE
highlight! LineNr      ctermbg=NONE guibg=NONE


""" Startup page
let g:startify_custom_header = startify#pad(split(system('tai ~/Pictures/mini-saborosa-crop.jpg'), '\n'))

""" General settings
filetype plugin on
if has('mouse') | set mouse=a | endif
set encoding=utf-8
set nocompatible
set noshowmode
set number relativenumber
set shiftwidth=2 softtabstop=2
set scrolloff=8
set showcmd
set confirm
set autoread

" Full evil
map <Left> <Nop>
map <Down> <Nop>
map <Up> <Nop>
map <Right> <Nop>

""" Key-bindings
let g:mapleader=" "

xnoremap K :move '<-2<CR>gv-gv
xnoremap J :move '>+1<CR>gv-gv
nnoremap H ^
nnoremap L $

nnoremap <leader>g :Goyo<CR><Esc>
nnoremap <leader><leader> /<++><CR>:nohlsearch<CR>ca<

nnoremap <leader>wh <C-w>h
nnoremap <leader>wj <C-w>j
nnoremap <leader>wk <C-w>k
nnoremap <leader>wl <C-w>l
nnoremap <leader>wc <C-w>c

nnoremap <leader>b] :bnext <CR>
nnoremap <leader>b[ :bprevious <CR>
nnoremap <leader>bd :bdelete <CR>

augroup TrimOnSave
  autocmd!
  autocmd BufWritePre * %s/\s\+$//e
  autocmd BufWritePre * %s/\n\+\%$//e
augroup END

""" Which-key
let g:which_key_map = {}
nnoremap <silent> <leader> :<c-u>WhichKey '<Space>'<CR>
vnoremap <silent> <leader> :<c-u>WhichKeyVisual '<Space>'<CR>

""" Ultsnips
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"
let g:UltiSnipsEditSplit="vertical"
highlight snipLeadingSpaces NONE

""" Haskell
let g:haskell_enable_quantification = 1   " to enable highlighting of `forall`
let g:haskell_enable_recursivedo = 1      " to enable highlighting of `mdo` and `rec`
let g:haskell_enable_arrowsyntax = 1      " to enable highlighting of `proc`
let g:haskell_enable_pattern_synonyms = 1 " to enable highlighting of `pattern`
let g:haskell_enable_typeroles = 1        " to enable highlighting of type roles
let g:haskell_enable_static_pointers = 1  " to enable highlighting of `static`
let g:haskell_backpack = 1                " to enable highlighting of backpack keywords
let g:haskell_indent_case_alternative = 1

""" LaTeX
let g:vimtex_compiler_enabled = 0

"" Compilation ---------------------------------------------------
function! LaTeX()
  let header = getline('1')
  let engine = header =~ "\% .*" ? strpart(header, 2) : "pdflatex"
  let tex = expand("%:p")
  let dir = expand("%:p:h")
  let bib = getline('2') == "\% use bib" ? ",bib_engine='biber'" : ""

  let cmd = join([
	\ "Rscript -e \"tinytex::",
	\ engine,
	\ "('",
	\ tex,
	\ "',engine_args='-synctex=1'",
	\ bib,
	\ ")\""
	\ ], "")

  echo "Running " . engine

  function! s:HandleOutput(job_id, data, event)
    if a:data == 0
      redraw
      echo "File compiled successfully!"
    else
      let log = expand("%:p:r") . ".log"
      if filereadable(log)
	let err = system("grep -A 1 '^!' " . log)
	echo err
      else
	echo "No log file " log " found!\n" out
      endif
    endif
  endfunction

  let job = jobstart("cd " . dir . " && " . cmd, { 'on_exit': function('s:HandleOutput') })

  return 0
endfunction
"" ---------------------------------------------------------------

"" SyncTeX -------------------------------------------------------
function! SyncTeXForward()
  let pdf = expand("%:p:r") . ".pdf"
  if filereadable(pdf)
    exec "silent !zathura --synctex-forward " . line(".") . ":" . col(".") . ":%:p %:p:r.pdf &"
  else
    echo "No pdf file found"
  endif

  return 0
endfunction
"" ---------------------------------------------------------------

augroup LaTeXuwu
  autocmd!
  autocmd BufEnter *.tex if !filereadable('/tmp/nvim-latex') | :call serverstart('/tmp/nvim-latex') | endif
  autocmd FileType tex nnoremap <leader>f :call SyncTeXForward()<CR>
  autocmd FileType tex nnoremap <leader>p :w<CR>:call LaTeX()<CR>
augroup END
