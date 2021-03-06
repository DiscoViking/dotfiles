set nocompatible

" Modeline and Notes. {
" vim: set foldmarker={,} foldlevel=0 foldmethod=marker:
" }

" Function for sourcing a file if it exists. {

function! Source(file)
  let l:filename = expand(a:file)
  if filereadable(l:filename)
    exec "silent source" . fnameescape(l:filename)
  endif
endfunction

" }

" Source other configuration files. {

  " If there's a local vimrc on this system, load it.
  " This is designed to allow for system-specific customization.
  call Source("~/.vimrc_local")

" }

" Vim-Plug for plugin management. {

  call plug#begin('~/.vim/plugged')

  " Navigation
  Plug 'kien/ctrlp.vim'
  Plug 'JazzCore/ctrlp-cmatcher', { 'do': './install.sh' }
  Plug 'rking/ag.vim'
  Plug 'vim-scripts/gtags.vim'

  " Informational
  " Use ale for asynchronous linting if we have Vim 8.
  " Otherwise syntastic
  if v:version >= 800
    Plug 'w0rp/ale'
  else
    Plug 'scrooloose/syntastic'
  endif
  Plug 'majutsushi/tagbar'

  " Source control
  Plug 'airblade/vim-gitgutter'
  Plug 'tpope/vim-fugitive'

  " Visual
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  Plug 'chriskempson/vim-tomorrow-theme'
  Plug 'sjl/badwolf'

  " Languages
  Plug 'rust-lang/rust.vim', { 'for': 'rust' }
  Plug 'fatih/vim-go', { 'for': 'go' }
  Plug 'pangloss/vim-javascript', { 'for': ['html', 'javascript'] }
  Plug 'leafgarland/typescript-vim', { 'for': 'typescript' }
  Plug 'udalov/kotlin-vim', { 'for': 'kotlin' }
  Plug 'elmcast/elm-vim'

  " Other
  Plug 'Shougo/vimproc.vim', { 'do': 'make' }

  " System local plugins
  call VimrcLocalPlugins()

  call plug#end()

" }

" General. {

  " Tab settings.
  set tabstop=8
  set softtabstop=4
  set shiftwidth=4
  set expandtab
  filetype plugin indent on

  " When creating a new line inside open brackets, match the indent of the
  " brackets.
  set cino+=(0

  " Search settings.
  set incsearch  "Search as you type
  set ignorecase "Ignore case by default
  set smartcase  "Ignore case if input string all lower-case

  " Tagging settings.
  set csprg=gtags-cscope  "Use gtags-cscope instead of cscope for tagging.
  " Add GTAGS tag database so cscope will use it.
  exe "silent! cs add " . expand("GTAGS")
  set csverb
  set cst                 "Makes cscope tags play nice with the tag stack.

  " Make backspace behave as expected.
  set backspace=indent,eol,start

  " Map W and Q to w and q so no more accidental failure to save/quit nonsense.
  command! W w
  command! Q q
  command! WQ wq
  command! Wq wq

  " Intentation for yaml.
  autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
" }

" Visual. {

  syntax on

  " Keep 3 lines below/above cursor visible at all times.
  set scrolloff=3

  " Don't highlight errors in shell scripts. Makes it play nice with my
  " custom rainbow parentheses settings for shell.
  let g:sh_no_error = 1

  " Use c syntax highlighting for .h files
  let g:c_syntax_for_h = 1

  " Color scheme - override background to be transparent.
  colorscheme badwolf
  hi Normal ctermbg=none
  hi NonText ctermbg=none
  hi SignColumn ctermbg=none
  hi Folded ctermbg=none
  hi DiffText ctermfg=Red
  let g:gitgutter_override_sign_column_highlight = 0

  " Rainbow Parentheses
  let g:rainbow_active = 1

  " Line numbers
  set relativenumber

  " If Vim > 7.4 enable hybrid line numbering mode.
  if v:version >= 704
    set number
  endif
  set colorcolumn=80

  " Highlight the current line.
  set cursorline

  " Set window title
  set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\ %{v:servername}
  set title

" }

" Airline configuration. {

  let g:airline_powerline_fonts = 1
  let g:airline#extensions#tabline#enabled = 1
  let g:airline_theme="badwolf"
  set laststatus=2

" }

" Ctrl-P options. {

  set wildignore+=*.tmp,*.swp,*.so,*.zip,*.o,*.d,*.pyc,*.class,node_modules,build,dist
  let g:ctrlp_max_files = 910000
  let g:ctrlp_use_caching = 1
  let g:ctrlp_switch_buffer = 'T'
  let g:ctrlp_clear_cache_on_exit = 0
  let g:ctrlp_dotfiles = 0
  let g:ctrlp_cache_dir = $HOME.'/.cache/ctrlp'

  " Use the cmatcher to perform matching. Much faster!
  " Necessary to use CtrlPGtags.
  " let g:ctrlp_match_func = {'match' : 'matcher#cmatch' }

" }

" YCM Setup {

  let g:ycm_add_preview_to_completeopt=0
  let g:ycm_show_diagnostics_ui = 0 " Disabled so we can use Syntastic checking in C

  " Fix YCM/Ultisnips compatibility
  function! g:UltiSnips_Complete()
    call UltiSnips#ExpandSnippet()
    if g:ulti_expand_res == 0
      if pumvisible()
        return "\<C-n>"
      else
        call UltiSnips#JumpForwards()
        if g:ulti_jump_forwards_res == 0
          return "\<TAB>"
        endif
      endif
    endif
    return ""
  endfunction

  " Only bother if UltiSnips is setup.
  if exists("g:UltiSnipsExpandTrigger")
    au BufEnter * exec "inoremap <silent> " . g:UltiSnipsExpandTrigger . " <C-R>=g:UltiSnips_Complete()<cr>"
    let g:UltiSnipsJumpForwardTrigger="<tab>"
    let g:UltiSnipsListSnippets="<c-e>"
    " this mapping Enter key to <C-y> to chose the current highlight item
    " and close the selection list, same as other IDEs.
    " CONFLICT with some plugins like tpope/Endwise
    inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
  endif

" }

" Python mode settings. {

  let g:pymode_folding=0 "Don't do folding.
  let g:pymode_rope=0    "Disables rope. This was causing huge lags in python files.

" }

" Syntastic settings. {

  let g:syntastic_python_checkers=['python']
  let g:syntastic_c_checkers=[]
  let g:syntastic_typescript_checkers=['tsc', 'tslint']
  let g:syntastic_typescript_tsc_fname = ''

" }

" ALE settings. {

  let g:ale_echo_msg_format = '[%linter%] %s'

  " Enable linting for Rust tests.
  let g:ale_rust_cargo_check_all_targets = 1

" }

" Key Binds. {

  noremap <leader>g :CtrlPGtags<CR>
  noremap <leader>s :cs<space>f<space>s<space>

  " Override for testing Gtags without cscope
  nmap <C-\>s :Gtags -r <C-R>=expand("<cword>")<CR><CR>
  nmap <C-\>g :cs f g <C-r><C-w><CR>
  nmap <C-\>n :cn<CR>
  nmap <C-\>p :cp<CR>

  " Bind U to redo.  This mimics the behaviour of [nN] which is nice.
  nnoremap U <C-r>

" }

" HARD MODE. {

  nnoremap <up> <nop>
  nnoremap <down> <nop>
  nnoremap <left> <nop>
  nnoremap <right> <nop>
  inoremap <up> <nop>
  inoremap <down> <nop>
  inoremap <left> <nop>
  inoremap <right> <nop>
  nnoremap j gj
  nnoremap k gk

" }

" Auto-format go files on save. {

  let g:go_fmt_command = "goimports"

  if executable("xclip")
    " Put contents of unnamed register into clipboard.
    command! Clip call system('xclip -i -selection clipboard', @")
    " Paste contents of clipboard into buffer.
    command! Clop put = system('xclip -o -selection clipboard')
  endif

" }

" Auto-format ELM files on save. {
  let g:elm_format_autosave = 1
" }

" Enable mouse control for idle scrolling. {

  " Selectively map only the mouse buttons we want.
  "set mouse=a
  map <ScrollWheelUp> 4<C-Y>
  map <ScrollWheelDown> 4<C-E>
  "map <LeftMouse> <nop>

  " Double left click goes to definition of tag under cursor.
  "map <2-LeftMouse> :cs f g <C-R>=expand("<cword>")<CR><CR><ESC>
  map <2-LeftMouse> <nop>
  map <3-LeftMouse> <nop>
  "map <LeftDrag> <nop>
  "map <LeftRelease> <nop>

  map <RightMouse> <nop>
  map <2-RightMouse> <nop>
  map <3-RightMouse> <nop>
  map <RightDrag> <nop>
  map <RightRelease> <nop>

" }

" Strip trailing whitespace on save. {

  fun! <SID>StripTrailingWhitespaces()
      let l = line(".")
      let c = col(".")
      %s/\s\+$//e
      call cursor(l, c)
  endfun

  autocmd FileType c,cpp,java,php,ruby,python,make,vim,sh,typescript autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()

  " Also highlight trailing whitespace so we can spot it in other filetypes.
  autocmd FileType c,cpp,java,php,ruby,python,go,make,vim,sh,typescript match Todo /\s\+$/
  hi Todo ctermbg=1 ctermfg=7

" }

" Window swap commands. {

  function! MarkWindowSwap()
    let g:markedWinNum = winnr()
  endfunction

  function! DoWindowSwap()
    "Mark destination
    let curNum = winnr()
    let curBuf = bufnr( "%" )
    exe g:markedWinNum . "wincmd w"
    "Switch to source and shuffle dest->source
    let markedBuf = bufnr( "%" )
    "Hide and open so that we aren't prompted and keep history
    exe 'hide buf' curBuf
    "Switch to dest and shuffle source->dest
    exe curNum . "wincmd w"
    "Hide and open so that we aren't prompted and keep history
    exe 'hide buf' markedBuf
  endfunction


  nmap <silent> <leader>mw :call MarkWindowSwap()<CR>
  nmap <silent> <leader>pw :call DoWindowSwap()<CR>

" }

" Source local override settings. {

  call VimrcLocalEnd()

" }
