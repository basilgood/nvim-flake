require('conform').setup({
  formatters = {
    shfmt = {
      prepend_args = { '-i', '2', '-ci' },
    },
    stylua = {
      prepend_args = {
        '--column-width',
        '120',
        '--indent-type',
        'Spaces',
        '--indent-width',
        '2',
        '--quote-style',
        'AutoPreferSingle',
      },
    },
  },
  formatters_by_ft = {
    lua = { 'stylua' },
    javascript = { 'prettier' },
    typescript = { 'prettier' },
    nix = { 'alejandra' },
    rust = { 'rustfmt' },
    sh = { 'shfmt' },
    yaml = { 'prettier' },
    json = { 'jq' },
    jsonc = { 'jq' },
  },
})

vim.keymap.set('n', 'Q', function()
  require('conform').format()
  vim.cmd.update()
end)
