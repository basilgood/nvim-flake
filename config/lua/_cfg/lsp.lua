local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities({
  workspace = {
    didChangeWatchedFiles = { dynamicRegistration = false },
  },
})

local opts = {
  flags = {
    debounce_text_changes = 150,
  },
  capabilities = capabilities,
}

lspconfig.eslint.setup({})
lspconfig.nil_ls.setup({ opts })
lspconfig.lua_ls.setup({
  opts,
  settings = {
    Lua = {
      diagnostics = {
        enable = true,
        globals = { 'vim' },
        disable = {
          'missing-fields',
          'no-unknown',
        },
      },
      workspace = {
        library = {
          vim.env.VIMRUNTIME,
        },
        checkThirdParty = false,
      },
    },
  },
})
lspconfig.rust_analyzer.setup({
  opts,
  settings = {
    ['rust-analyzer'] = {
      imports = {
        granularity = {
          group = 'module',
        },
        prefix = 'self',
      },
      cargo = {
        buildScripts = {
          enable = true,
        },
      },
      procMacro = {
        enable = true,
      },
    },
  },
})
