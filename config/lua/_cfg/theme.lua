require('catppuccin').setup({
  term_colors = true,
  integrations = {
    markdown = true,
    notify = true,
    semantic_tokens = true,
    telescope = true,
  },
  custom_highlights = function()
    return {
      MiniIndentscopeSymbol = { fg = '#49496d' },
      TelescopeBorder = { fg = '#49496d', bg = '#1a1a28' },
      TelescopeTitle = { fg = '#6b6ba0' },
    }
  end,
})

vim.cmd.colorscheme('catppuccin-mocha') -- latte, frappe, macchiato, mocha
