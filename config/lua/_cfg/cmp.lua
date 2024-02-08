local cmp = require('cmp')
local lspkind = require('lspkind')
local select_opts = { behavior = cmp.SelectBehavior.Select }
local replace_opts = { behavior = cmp.ConfirmBehavior.Replace, select = false }

cmp.setup({
  preselect = cmp.PreselectMode.None,
  snippet = {
    expand = function(args)
      require('snippy').expand_snippet(args.body)
    end,
  },
  window = {
    completion = {
      border = 'single',
      winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:Visual,Search:None',
      col_offset = 0,
      side_padding = 0,
    },
    documentation = {
      border = 'single',
      winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:Visual,Search:None',
    },
  },
  mapping = {
    ['<up>'] = cmp.mapping.select_prev_item(select_opts),
    ['<down>'] = cmp.mapping.select_next_item(select_opts),
    ['<tab>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' }),
    ['<s-tab>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 's' }),
    ['<cr>'] = cmp.mapping.confirm(replace_opts),
    ['<c-e>'] = cmp.mapping.abort(),
  },
  sources = {
    { name = 'snippy', max_item_count = 5, group_index = 1 },
    { name = 'nvim_lsp', max_item_count = 20, group_index = 1 },
    { name = 'async_path', group_index = 2 },
    { name = 'buffer', keyword_length = 2, max_item_count = 5, group_index = 2 },
  },
  formatting = {
    fields = { 'abbr', 'kind', 'menu' },
    format = function(_, item)
      item.kind = lspkind.presets.codicons[item.kind] .. ' ' .. item.kind
      item.abbr = item.abbr:match('[^(]+')

      return item
    end,
  },
})

require('snippy').setup({
  mappings = {
    is = {
      ['<c-l>'] = 'expand_or_advance',
      ['<c-h>'] = 'previous',
    },
  },
})
require('lsp_signature').setup({ floating_window = false })
vim.keymap.set('n', '<C-k>', function()
  require('lsp_signature').toggle_float_win()
end)
