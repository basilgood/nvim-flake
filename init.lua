-- init
-- utils
local fn = vim.fn
local cmd = vim.cmd
local com = vim.api.nvim_command
local g = vim.g
local vim = vim

local scopes = {o = vim.o, b = vim.bo, w = vim.wo}

local function opt(scope, key, value)
  scopes[scope][key] = value
  if scope ~= 'o' then scopes['o'][key] = value end
end

local function map(mode, lhs, rhs, opts)
  local options = {noremap = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- netrw
g.netrw_altfile = 1
g.netrw_preview = 1
g.netrw_altv = 1
g.netrw_alto = 0
g.netrw_use_errorwindow = 0
g.netrw_localcopydircmd = 'cp -r'

-- packages
local user_install_path = fn.stdpath('data') ..
                              '/site/pack/user/opt/faerryn/user.nvim/default/default'
if fn.empty(fn.glob(user_install_path)) > 0 then
  os.execute(
      [[git clone --depth 1 https://github.com/faerryn/user.nvim.git ']] ..
          user_install_path .. [[']])
end
com('packadd faerryn/user.nvim/default/default')

local user = require 'user'
user.setup()
local use = user.use

use 'faerryn/user.nvim'

-- navigation
use {
  'tpope/vim-vinegar',
  after = 'basilgood/barow',
  config = function()
    cmd 'autocmd FileType netrw nmap <buffer><silent> <right> <cr>'
    cmd 'autocmd FileType netrw nmap <buffer><silent> <left> -'
    cmd 'autocmd FileType netrw nmap <buffer> <c-x> mfmx'
  end
}

use {'junegunn/fzf', after = 'basilgood/barow'}
use {
  'junegunn/fzf.vim',
  after = 'junegunn/fzf',
  config = function()
    cmd([[
      let $FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude plugged'
      let $FZF_PREVIEW_COMMAND = 'bat --color=always --style=plain -n -- {} || cat {}'
    ]])
    map('n', '<c-p>', ':Files<CR>')
    map('n', '<bs>', ':Buffers<CR>')
  end
}

-- completion
use {
  'nvim-lua/completion-nvim',
  config = function()
    map('i', '<Tab>', [[pumvisible() ? "\<C-n>" : "\<Tab>"]], {expr = true})
    map('i', '<S-Tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], {expr = true})
    cmd('autocmd BufEnter * lua require"completion".on_attach()')
  end
}

-- lint
use {
  'dense-analysis/ale',
  config = function()
    g.ale_disable_lsp = 1
    g.ale_sign_error = '• '
    g.ale_sign_warning = '• '
    g.ale_set_highlights = 0
    g.ale_lint_on_text_changed = 'normal'
    g.ale_lint_on_insert_leave = 1
    g.ale_lint_delay = 0
    g.ale_echo_msg_format = '%s'
    map('n', '[a', '<Plug>(ale_previous_wrap)', {noremap = false})
    map('n', ']a', '<Plug>(ale_next_wrap)', {noremap = false})
    g.ale_fixers = {
      css = 'prettier',
      javascript = 'eslint',
      typescript = 'tslint',
      json = 'prettier',
      scss = 'prettier',
      yml = 'prettier',
      html = 'eslint',
      rust = 'rustfmt'
    }
  end
}
use 'nathunsmitty/nvim-ale-diagnostic'

-- lsp
use {
  'neovim/nvim-lspconfig',
  config = function()
    local lspconfig = require('lspconfig')
    local on_attach = function()
      require('nvim-ale-diagnostic')
      vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
                                                                vim.lsp
                                                                    .diagnostic
                                                                    .on_publish_diagnostics,
                                                                {
            underline = false,
            virtual_text = false,
            signs = true,
            update_in_insert = false
          })
      map('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>')
      map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
      map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
      map('n', 'ca', '<cmd>lua vim.lsp.buf.code_action()<CR>')
      map('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>')
      map('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>')
      fn.sign_define('LspDiagnosticsSignError', {text = '•'})
      fn.sign_define('LspDiagnosticsSignWarning', {text = '•'})
      fn.sign_define('LspDiagnosticsSignInformation', {text = '•'})
      fn.sign_define('LspDiagnosticsSignHint', {text = '•'})
    end
    lspconfig.tsserver.setup {on_attach = on_attach}
  end
}

-- syntax
use {
  'nvim-treesitter/nvim-treesitter',
  config = function()
    local ts_config = require('nvim-treesitter.configs')
    ts_config.setup {
      ensure_installed = {
        'javascript', 'typescript', 'jsdoc', 'json', 'html', 'css', 'bash',
        'lua'
      },
      highlight = {enable = true, use_languagetree = true}
    }
  end
}
use 'maxmellon/vim-jsx-pretty'
use 'yuezk/vim-js'
use 'LnL7/vim-nix'

-- formatter
use {
  'mhartington/formatter.nvim',
  after = 'basilgood/barow',
  config = function()
    require('formatter').setup({
      logging = false,
      filetype = {
        javascript = {
          -- prettier
          function()
            return {
              exe = 'prettier',
              args = {
                '--stdin-filepath', vim.api.nvim_buf_get_name(0),
                '--single-quote', '--trailing-comma', 'none', '--arrow-parens',
                'avoid'
              },
              stdin = true
            }
          end
        },
        nix = {
          -- nixpkgs-fmt
          function() return {exe = 'nixpkgs-fmt', stdin = true} end
        },
        lua = {
          -- luafmt
          function()
            return {
              exe = 'lua-format',
              args = {
                '--indent-width', 2, '--tab-width', 2,
                '--double-quote-to-single-quote'
              },
              stdin = true
            }
          end
        }
      }
    })
  end
}

-- git
use {
  'tpope/vim-fugitive',
  config = function()
    map('n', 'gs', ':tab G<cr>')
    cmd 'autocmd FileType fugitive nnoremap <buffer> gpp :G push<cr>'
    cmd 'autocmd FileType fugitive nnoremap <buffer> gpf :G push -f<cr>'
  end
}
use {
  'airblade/vim-gitgutter',
  config = function()
    g.gitgutter_sign_priority = 8
    g.gitgutter_override_sign_column_highlight = 0
    map('n', 'ghs', '<Plug>(GitGutterStageHunk)', {noremap = false})
    map('n', 'ghu', '<Plug>(GitGutterUndoHunk)', {noremap = false})
    map('n', 'ghp', '<Plug>(GitGutterPreviewHunk)', {noremap = false})
  end
}
use 'gotchane/vim-git-commit-prefix'
use 'hotwatermorning/auto-git-diff'
use 'whiteinge/diffconflicts'
use 'junegunn/gv.vim'

-- misc
use 'editorconfig/editorconfig-vim'
use 'basilgood/vim-system-copy'
use 'kevinhwang91/nvim-bqf'
use 'wellle/targets.vim'
use 'michaeljsmith/vim-indent-object'
use 'tpope/vim-surround'
use 'tpope/vim-repeat'
use {
  'windwp/nvim-autopairs',
  config = function() require('nvim-autopairs').setup() end
}
use {
  'terrortylor/nvim-comment',
  config = function() require('nvim_comment').setup({comment_empty = false}) end
}
use 'pgdouyon/vim-evanesco'
use 'sgur/cmdline-completion'
use {
  'haya14busa/vim-asterisk',
  config = function()
    map('n', '*', '<Plug>(asterisk-z*)', {noremap = false})
    map('v', '*', '<Plug>(asterisk-z*)', {noremap = false})
  end
}
use {
  'antoinemadec/FixCursorHold.nvim',
  init = function() g.cursorhold_updatetime = 100 end
}
use {
  'mbbill/undotree',
  config = function()
    g.undotree_WindowLayout = 4
    g.undotree_SetFocusWhenToggle = 1
    g.undotree_ShortIndicators = 1
  end
}
use {
  'romgrk/winteract.vim',
  config = function() map('n', 'gw', '<cmd>InteractiveWindow<CR>') end
}
use {
  'mileszs/ack.vim',
  config = function()
    g.ackprg = 'rg --vimgrep'
    g.ackhighlight = 1
    map('c', 'Ack', 'Ack!')
  end
}
use {
  'norcalli/nvim-colorizer.lua',
  after = 'basilgood/tokyodark.nvim',
  config = function() require'colorizer'.setup() end
}

-- theme and statusline
use {
  'basilgood/tokyodark.nvim',
  config = function() cmd 'colorscheme tokyodark' end
}
use {'basilgood/barow', after = 'basilgood/tokyodark.nvim'}

user.startup()

-- options
opt('o', 'path', '.,**')
opt('b', 'swapfile', false)
opt('o', 'writebackup', false)
opt('o', 'undofile', true)
opt('o', 'autowrite', true)
opt('o', 'autowriteall', true)
opt('w', 'number', true)
opt('o', 'termguicolors', true)
opt('o', 'lazyredraw', true)
opt('o', 'gdefault', true)
opt('w', 'wrap', false)
opt('o', 'linebreak', true)
opt('o', 'showbreak', 'string.rep(" ", 3)')
opt('w', 'breakindent', true)
opt('w', 'breakindentopt', 'sbr')
opt('o', 'mouse', 'a')
-- opt('o', 'grepprg', 'rg --vimgrep')
-- opt('o', 'grepformat', '%f:%l:%c:%m')
opt('o', 'incsearch', true)
opt('o', 'completeopt', 'menuone,noinsert,noselect')
opt('o', 'shortmess', 'aoOTIcF')
opt('o', 'showmode', false)
opt('o', 'sidescroll', 1)
opt('o', 'sidescrolloff', 5)
opt('o', 'splitbelow', true)
opt('o', 'splitright', true)
opt('o', 'switchbuf', 'useopen,uselast')
opt('b', 'expandtab', true)
opt('b', 'tabstop', 2)
opt('b', 'softtabstop', 2)
opt('b', 'shiftwidth', 2)
opt('b', 'smartindent', true)
opt('o', 'confirm', true)
opt('o', 'inccommand', 'nosplit')
opt('o', 'pumheight', 10)
opt('o', 'updatetime', 50)
opt('o', 'ttimeoutlen', 0)
opt('o', 'timeoutlen', 2000)
opt('o', 'wildcharm', 9)
opt('o', 'wildignorecase', true)
opt('o', 'wildignore', '*/.git,*/node_modules,')
opt('o', 'diffopt',
    'internal,filler,closeoff,context:3,algorithm:patience,indent-heuristic')
opt('w', 'list', true)
opt('w', 'listchars', 'tab:┊ ,trail:•,nbsp:␣,extends:↦,precedes:↤')
-- opt('o', 'statusline', table.concat({
--   ' %t ', '%m', '%=', '%{&filetype} ', '%2c:%l/%L '
-- }))

-- mappings
-- easy swith windows
map('n', '<leader><leader>', '<c-w>w')
-- when wrap
map('', 'j', 'v:count == 0 ? "gj" : "j"', {silent = true, expr = true})
map('', 'k', 'v:count == 0 ? "gk" : "k"', {silent = true, expr = true})
-- redline
map('c', '<C-a>', '<Home>')
map('c', '<C-e>', '<End>')
map('i', '<C-a>', '<Home>')
map('i', '<C-e>', '<End>')
-- center
map('n', '}', '}zz')
map('n', '{', '{zz')
map('n', '<space>gf', [[:vertical wincmd f<cr>]])
map('n', '<C-g>', [[:echon '['.expand("%:p:~").'] '.'[L:'.line('$').']']] ..
        [[<Bar>echon ' ['system("git rev-parse --abbrev-ref HEAD 2>/dev/null \| tr -d '\n'")']'<cr>]])
-- objects
map('x', 'I', [[mode()=~#'[vV]'?'<C-v>^o^I':'I']], {expr = true})
map('x', 'A', [[mode()=~#'[vV]'?'<C-v>0o$A':'A']], {expr = true})
map('v', 'il', [[<Esc>^vg_]], {silent = true})
map('o', 'il', [[:<C-U>normal! ^vg_<cr>]])
map('v', 'ie', 'gg0oG$')
-- paste from change
map('v', 'P', '"0p')
-- substitute
map('n', 'ss', [[:%s/]])
map('n', 'sl', [[:s/]])
map('v', 'ss', [[:s/]])
-- search and replace
map('n', 'sn', '*Ncgn')
-- execute macro
map('n', 'Q', '@q')
map('v', 'Q', [[:norm Q<cr>]])
-- copy/move from cmdline
map('c', '<c-x>t', [[<CR>:t''<CR>]])
map('c', '<c-x>m', [[<CR>:m''<CR>]])
map('c', '<c-x>d', [[<CR>:d<CR>``]])

-- autocommands
cmd 'autocmd TextYankPost * lua vim.highlight.on_yank {higroup = "Search", timeout = 300}'
cmd([[autocmd BufReadPost * if line("'\"") >= 1 && line("'\"") <= line("$")]] ..
        [[&& &ft !~# 'commit' | exe "normal! g`\"" | endif]])
cmd 'autocmd FileType qf wincmd J'
cmd 'autocmd BufWinEnter * if &ft == "help" | wincmd J | end'
cmd 'autocmd InsertLeave * if &l:diff | diffupdate | endif'
cmd 'autocmd BufWritePre * if !isdirectory(expand("%:h", v:true)) | call mkdir(expand("%:h", v:true), "p") | endif'
cmd 'autocmd! VimResume, CursorHold * checktime'
cmd 'autocmd! VimResume, CursorHold * if exists("g:loaded_gitgutter") | call gitgutter#all(1) | endif'
cmd 'autocmd InsertLeave * set nopaste'
cmd 'autocmd BufNewFile,BufRead config setlocal filetype=config'
cmd 'autocmd BufWinEnter *.json setlocal conceallevel=0 concealcursor='
cmd 'autocmd BufReadPre *.json setlocal conceallevel=0 concealcursor='
cmd 'autocmd BufReadPre *.json setlocal formatoptions='
cmd 'autocmd FileType git setlocal nofoldenable'
cmd 'autocmd FileType gitcommit setlocal spell | setlocal textwidth=72 | setlocal colorcolumn=+1'
cmd 'autocmd TermOpen * setlocal nonumber norelativenumber'
cmd 'autocmd TermOpen * if &buftype ==# "terminal" | startinsert | endif'
cmd 'autocmd BufLeave term://* stopinsert'
cmd [[autocmd TermClose term://* if (expand('<afile>') !~ "fzf") | call nvim_input('<CR>') | endif]]
cmd 'autocmd Filetype * if &omnifunc == "" | setlocal omnifunc=syntaxcomplete#Complete | endif'

-- sessions
if fn.empty(fn.glob('~/.cache/sessions')) > 0 then
  os.execute 'mkdir -p ~/.cache/sessions'
end
cmd 'autocmd! VimLeavePre * execute "mksession! ~/.cache/sessions/" . split(getcwd(), "/")[-1] . ".vim"'
com(
    [[command! -nargs=0 SS :execute 'source ~/.cache/sessions/' .  split(getcwd(), '/')[-1] . '.vim']])

--- commands
com([[command! -nargs=0 BO silent! execute "%bd|e#|bd#"]])
com([[command BD bp | bd #]])
com([[command! -nargs=0 WS %s/\s\+$// | normal! ``]])
com([[command! -nargs=0 WT %s/[^\t]\zs\t\+/ / | normal! ``]])
com([[command! -bar HL echo synIDattr(synID(line('.'),col('.'),0),'name')]] ..
        [[synIDattr(synIDtrans(synID(line('.'),col('.'),1)),'name')]])
com([[command! WW w !sudo tee % > /dev/null]])

-- clean packages
cmd 'autocmd VimLeavePre * lua require"user".clean()'

vim.o.exrc = true
vim.o.secure = true
