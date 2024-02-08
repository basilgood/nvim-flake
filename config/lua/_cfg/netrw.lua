local g = vim.g
local autocmd = vim.api.nvim_create_autocmd
local map = vim.keymap.set

g.netrw_list_hide = '^./$,^../$'
g.netrw_bufsettings = 'noma nomod nonu nobl nowrap ro nocul scl=no'
g.netrw_banner = 0
g.netrw_preview = 1
g.netrw_alto = 'spr'
g.netrw_use_errorwindow = 0
g.netrw_special_syntax = 1
g.netrw_localcopydircmd = 'cp -r'
g.netrw_localrmdir = 'rm -r'

map('n', '-', function()
  local file = vim.fn.expand('%:t')
  vim.fn.execute('Explore')
  vim.fn.expand('%:h')
  vim.fn.search(file, 'wc')
end)

local netrw_mapping = function()
  local opts = { buffer = true, remap = true }
  map('n', '<tab>', 'mf', opts)
  map('n', '<esc>', 'mF', opts)
  map('n', '.', 'mfmx', opts)
  map('n', 'P', '<cmd>wincmd w|bd|wincmd c<cr>', opts)
end

autocmd('filetype', {
  pattern = 'netrw',
  desc = 'netrw keymapings',
  callback = netrw_mapping,
})
