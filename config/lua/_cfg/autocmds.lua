local vimRc = vim.api.nvim_create_augroup('vimRc', { clear = true })
local autocmd = vim.api.nvim_create_autocmd

autocmd('TextYankPost', {
  group = vimRc,
  callback = function()
    vim.highlight.on_yank()
  end,
})
autocmd('FileType', {
  group = vimRc,
  pattern = {
    'help',
    'man',
    'qf',
    'query',
    'scratch',
  },
  callback = function(args)
    vim.keymap.set('n', 'q', '<cmd>quit<cr>', { buffer = args.buf })
  end,
})
autocmd('FileType', { pattern = { 'qf', 'help', 'man' }, group = vimRc, command = 'wincmd J' })
autocmd('FileType', { group = vimRc, pattern = '*', command = 'set formatoptions-=o' })
autocmd('BufRead', { pattern = '*', group = vimRc, command = [[call setpos(".", getpos("'\""))]] })
autocmd('BufReadPre', {
  pattern = '*.json',
  group = vimRc,
  command = 'setlocal conceallevel=0 concealcursor= formatoptions=',
})
autocmd('BufReadPre', {
  pattern = '*{.md,.markdown}',
  group = vimRc,
  command = 'setlocal conceallevel=2 concealcursor=vc',
})
autocmd('TermOpen', {
  callback = function(cmd_args)
    core.startinsert()

    autocmd('BufEnter', {
      buffer = cmd_args.buf,
      callback = function()
        core.startinsert()
        vim.cmd('redraw')
      end,
    })
  end,
})
