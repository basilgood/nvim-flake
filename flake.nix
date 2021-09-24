{
  description = "neovim with config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      rec {
        packages = with pkgs;  rec {
          devShell = mkShell {
            buildInputs = [
              nodePackages.prettier
              nixpkgs-fmt
              shfmt
              yamllint
              ripgrep
              fd
              (pkgs.neovim.override {
                configure = {
                  customRC = ''
                    " fzf
                    let $FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude plugged'
                    let $FZF_PREVIEW_COMMAND = 'bat --color=always --style=plain -n -- {} || cat {}'
                    let g:fzf_layout = {'window': { 'width': 0.7, 'height': 0.4,'yoffset':0.85,'xoffset': 0.5 } }
                    nnoremap <c-p> :Files<cr>
                    nnoremap <bs> :Buffers<cr>

                    " netrw
                    let g:netrw_altfile = 1
                    let g:netrw_preview = 1
                    let g:netrw_altv = 1
                    let g:netrw_alto = 0
                    let g:netrw_use_errorwindow = 0
                    let g:netrw_localcopydircmd = 'cp -r'
                    let g:netrw_list_hide = '^\.\.\=/\=$'
                    function! s:innetrw() abort
                      nmap <buffer><silent> <right> <cr>
                      nmap <buffer><silent> <left> -
                      nmap <buffer> <c-x> mfmx
                    endfunction
                    autocmd FileType netrw call s:innetrw()

                    " ack
                    let g:ackprg = "rg --vimgrep"
                    let g:ackhighlight = 1
                    cnoreabbrev Ack Ack!

                    " completion
                    let g:completion_enable_in_comment    = 1
                    let g:completion_auto_change_source   = 1
                    let g:completion_trigger_keyword_length = 2
                    inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
                    inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
                    autocmd BufEnter * lua require"completion".on_attach()
                    set omnifunc=v:lua.vim.lsp.omnifunc
                    set completeopt=menuone,noinsert,noselect
                    set shortmess+=c

                    " ale
                    let g:ale_disable_lsp = 1
                    let g:ale_sign_error = '• '
                    let g:ale_sign_warning = '• '
                    let g:ale_set_highlights = 0
                    let g:ale_lint_on_text_changed = 'normal'
                    let g:ale_lint_on_insert_leave = 1
                    let g:ale_lint_delay = 0
                    let g:ale_echo_msg_format = '%s'
                    nmap [a <Plug>(ale_next_wrap)
                    nmap ]a <Plug>(ale_previous_wrap)
                    let g:ale_fixers = {
                        \   'javascript': ['eslint'],
                        \   'typescript': ['eslint'],
                        \   'nix': ['nixpkgs-fmt'],
                        \   'sh': ['shfmt']
                        \ }

                    " lsp
                    lua << EOF
                    local lspconfig = require('lspconfig')
                    local on_attach = function()
                      require('nvim-ale-diagnostic')
                      vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
                        vim.lsp.diagnostic.on_publish_diagnostics, {
                          underline = false,
                          virtual_text = false,
                          signs = true,
                          update_in_insert = false
                        }
                      )
                      vim.cmd[[nnoremap gd :lua vim.lsp.buf.definition()<cr>]]
                      vim.cmd[[nnoremap gr :lua vim.lsp.buf.references()<cr>]]
                      vim.cmd[[nnoremap gs :lua vim.lsp.buf.signature_help()<cr>]]
                      vim.cmd[[nnoremap K :lua vim.lsp.buf.hover()<cr>]]
                      vim.cmd[[nnoremap ga :lua vim.lsp.buf.code_action()<cr>]]
                      vim.cmd[[nnoremap [d :lua vim.lsp.diagnostic.goto_prev()<cr>]]
                      vim.cmd[[nnoremap ]d :lua vim.lsp.diagnostic.goto_next()<cr>]]
                      vim.fn.sign_define('LspDiagnosticsSignError', {text = '•'})
                      vim.fn.sign_define('LspDiagnosticsSignWarning', {text = '•'})
                      vim.fn.sign_define('LspDiagnosticsSignInformation', {text = '•'})
                      vim.fn.sign_define('LspDiagnosticsSignHint', {text = '•'})
                    end
                    lspconfig.tsserver.setup {on_attach = on_attach}
                    EOF

                    " treesitter
                    lua << EOF
                    require'nvim-treesitter.configs'.setup {
                        ensure_installed = {
                          'javascript', 'typescript', 'jsdoc', 'json', 'html', 'css', 'bash',
                          'lua', 'nix'
                        },
                        highlight = {enable = true, additional_vim_regex_highlighting = false},
                        indent = {enable = true}
                      }
                    EOF

                    set path+=**
                    set autoread autowrite autowriteall
                    set noswapfile
                    set nowritebackup
                    set undofile
                    set number
                    set mouse=a
                    set shortmess=aoOTIcF
                    set splitright splitbelow
                    set lazyredraw
                    set inccommand=nosplit
                    set termguicolors
                    set lazyredraw
                    set gdefault
                    set tabstop=2
                    set softtabstop=2
                    set shiftwidth=2
                    set shiftround
                    set expandtab
                    set smartindent
                    set nowrap
                    set incsearch hlsearch
                    set confirm
                    set pumheight=10
                    set updatetime=50
                    set ttimeoutlen=0
                    set timeoutlen=2000
                    set wildcharm=9
                    set wildmode=longest:full,full
                    set wildignorecase
                    set diffopt+=context:3,indent-heuristic,algorithm:patience
                    set list
                    set listchars=tab:⇥\ ,trail:•,nbsp:␣,extends:↦,precedes:↤
                    autocmd InsertEnter * set listchars-=trail:•
                    autocmd InsertLeave * set listchars+=trail:•
                    set statusline=%<%.99f\ %y%h%w%m%r%=%-14.(%l,%c%V%)\ %L
                    autocmd TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=300}
                    autocmd BufReadPost *
                          \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
                          \ |   exe "normal! g`\""
                          \ | endif
                    autocmd BufReadPre *.json  setlocal conceallevel=0 concealcursor=
                    autocmd BufReadPre *.json  setlocal formatoptions=
                    nnoremap <silent> <C-g> :echon '['.expand("%:p:~").']'.' [L:'.line('$').']'<Bar>echon ' ['system("git rev-parse --abbrev-ref HEAD 2>/dev/null \| tr -d '\n'")']'<CR>
                    nnoremap <silent><expr> <C-l> empty(get(b:, 'current_syntax'))
                          \ ? "\<C-l>"
                          \ : "\<C-l>:syntax sync fromstart\<cr>:nohlsearch<cr>"

                    colorscheme hybrid_material
                  '';
                  packages.myVimPackage = with pkgs.vimPlugins; {
                    start = [
                      ale
                      nvim-ale-diagnostic
                      nvim-lspconfig
                      completion-nvim
                      nvim-treesitter
                      vinegar
                      commentary
                      surround
                      repeat
                      vim-nix
                      fzf
                      fzf-vim
                      ack
                      is-vim
                      editorconfig-vim
                    ];
                    opt = [ vim-hybrid-material ];
                  };
                };
              })
            ];
          };
        };
        defaultPackage = packages.devShell;
      }
    );
}
