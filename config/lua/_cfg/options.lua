local o = vim.opt

o.swapfile = false
o.termguicolors = true
o.shiftwidth = 2
o.tabstop = 2
o.expandtab = true
o.gdefault = true
o.number = true
o.wrap = false
o.linebreak = true
o.breakindent = true
o.splitbelow = true
o.splitright = true
o.splitkeep = 'screen'
o.undofile = true
o.autowrite = true
o.autowriteall = true
o.confirm = true
o.signcolumn = 'yes'
o.numberwidth = 3
o.updatetime = 300
o.timeoutlen = 2000
o.ttimeoutlen = 10
o.completeopt = 'menuone,noselect,noinsert'
o.complete:remove('t')
o.pumheight = 5
o.wildmode = 'longest:full,full'
o.diffopt = 'internal,filler,closeoff,context:3,indent-heuristic,algorithm:patience,linematch:60'
o.sessionoptions = 'buffers,curdir,tabpages,folds,winpos,winsize'
o.list = true
o.listchars = { lead = '⋅', trail = '⋅', tab = '┊ ·', nbsp = '␣' }
-- o.listchars = { lead = '⋅', trail = '⋅', tab = ' ·', nbsp = '␣' }
o.shortmess:append({
  I = true,
  w = true,
  s = true,
})
o.fillchars = {
  eob = ' ',
  diff = ' ',
  -- vert = '▒',
}
o.grepprg = 'rg --color=never --vimgrep'
o.grepformat = '%f:%l:%c:%m'
o.laststatus = 3
