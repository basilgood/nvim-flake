local telescope = require('telescope')
local lga_actions = require('telescope-live-grep-args.actions')

telescope.setup({
  defaults = {
    path_display = { 'truncate' },
    dynamic_preview_title = true,
    borderchars = { '┄', '┊', '┄', '┊', '╭', '╮', '╯', '╰' },
    layout_strategy = 'vertical',
    layout_config = {
      preview_cutoff = 0,
    },
    mappings = {
      i = {
        ['<esc>'] = require('telescope.actions').close,
        ['<c-k>'] = require('telescope.actions').delete_buffer,
      },
    },
    generic_sorter = require('mini.fuzzy').get_telescope_sorter,
  },
  pickers = {
    find_files = { find_command = { 'fd', '-tf', '-L', '-H', '-E=.git', '-E=node_modules', '--strip-cwd-prefix' } },
  },
  extensions = {
    live_grep_args = {
      auto_quoting = true,
      mappings = {
        i = {
          ['<C-k>'] = lga_actions.quote_prompt(),
          ['<C-i>'] = lga_actions.quote_prompt({ postfix = ' --iglob ' }),
        },
      },
    },
    undo = {
      initial_mode = 'normal',
    },
  },
})
telescope.load_extension('live_grep_args')

vim.keymap.set('n', '<c-p>', '<cmd>Telescope find_files<cr>', {})
vim.keymap.set('n', '<bs>', '<cmd>Telescope buffers show_all_buffers=true sort_mru=true sort_lastused=true<cr>', {})
vim.keymap.set('n', '<leader>w', '<cmd>Telescope grep_string<cr>', {})
vim.keymap.set('n', '<leader>g', telescope.extensions.live_grep_args.live_grep_args, {})
