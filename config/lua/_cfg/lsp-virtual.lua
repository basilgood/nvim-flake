require('lsp-virtual-improved').setup()
vim.diagnostic.config({
  virtual_text = false,
  underline = false,
  float = {
    focusable = false,
    style = 'minimal',
    border = 'single',
    source = 'always',
    header = '',
    prefix = '',
  },
  virtual_improved = {
    current_line = 'only',
  },
})
