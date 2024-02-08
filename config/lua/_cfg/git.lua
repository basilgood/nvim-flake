if vim.fn.executable('nvr') == 1 then
  vim.env.GIT_EDITOR = "nvr --remote-tab-wait +'set bufhidden=delete'"
end

require('neogit').setup({})
local gs = require('gitsigns')
local map = vim.keymap.set

gs.setup({
  signs = { untracked = { text = '' } },
  _signs_staged_enable = true,
  _signs_staged = {
    add = { text = '┋ ' },
    change = { text = '┋ ' },
    delete = { text = '﹍' },
    topdelete = { text = '﹉' },
    changedelete = { text = '┋ ' },
  },
  on_attach = function()
    map('n', '[c', gs.prev_hunk, { buffer = true })
    map('n', ']c', gs.next_hunk, { buffer = true })
    -- Actions
    map('n', 'ghs', gs.stage_hunk)
    map('n', 'ghr', gs.reset_hunk)
    map('v', 'ghs', function()
      gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end)
    map('v', 'ghr', function()
      gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end)
    map('v', 'ghu', function()
      gs.undo_stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end)
    map('n', 'ghS', gs.stage_buffer)
    map('n', 'ghu', gs.undo_stage_hunk)
    map('n', 'ghR', gs.reset_buffer)
    map('n', 'ghp', gs.preview_hunk)
    map('n', 'ghB', function()
      gs.blame_line({ full = true })
    end)
    map('n', 'ghb', gs.toggle_current_line_blame)
    map('n', 'ghd', gs.diffthis)
    map('n', 'ghD', function()
      gs.diffthis('~')
    end)
    map('n', 'ghx', gs.toggle_deleted)
    -- Text object
    map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end,
})
