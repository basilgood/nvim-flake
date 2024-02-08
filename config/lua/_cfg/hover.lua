require('hover').setup({
  init = function()
    require('hover.providers.lsp')
    require('hover.providers.man')
    require('hover.providers.dictionary')
  end,
})

vim.keymap.set('n', 'K', require('hover').hover, { desc = 'hover.nvim' })
