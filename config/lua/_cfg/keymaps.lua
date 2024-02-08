local map = vim.keymap.set
map('n', ']q', ':cnext<cr>')
map('n', '[q', ':cprev<cr>')
map('n', '<C-w>z', [[:wincmd z<bar>cclose<bar>lclose<cr>]], { silent = true })
map('n', '3<C-g>', [[:echo system('cat .git/HEAD')->split('\n')<cr>]])
map('n', 'vv', 'viw', { silent = true })
map('x', 'il', 'g_o^', { silent = true })
map('o', 'il', ':normal vil<cr>', { silent = true })
map('n', '[d', vim.diagnostic.goto_prev)
map('n', ']d', vim.diagnostic.goto_next)
map('n', 'gl', vim.diagnostic.open_float)
map('n', 'z=', function()
  local word = vim.fn.expand('<cword>')
  local suggestions = vim.fn.spellsuggest(word)
  vim.ui.select(
    suggestions,
    {},
    vim.schedule_wrap(function(selected)
      if selected then
        vim.cmd.normal({ args = { 'ciw' .. selected }, bang = true })
      end
    end)
  )
end)
