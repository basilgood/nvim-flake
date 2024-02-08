{
  description = "neovim flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";

    "plugin:typescript-tools" = {
      url = "github:pmizio/typescript-tools.nvim";
      flake = false;
    };
    "plugin:format-ts-errors" = {
      url = "github:davidosomething/format-ts-errors.nvim";
      flake = false;
    };
    "plugin:lsp-virtual-improved" = {
      url = "github:luozhiya/lsp-virtual-improved.nvim";
      flake = false;
    };
    "plugin:yati" = {
      url = "github:yioneko/nvim-yati";
      flake = false;
    };
    "plugin:mini-nvim" = {
      url = "github:echasnovski/mini.nvim";
      flake = false;
    };
    "plugin:vim-star" = {
      url = "github:linjiX/vim-star";
      flake = false;
    };
    "plugin:auto-save" = {
      url = "github:okuuva/auto-save.nvim";
      flake = false;
    };
    "plugin:arrow" = {
      url = "github:otavioschwanck/arrow.nvim";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    neovim-nightly,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pluginOverlay = final: prev: let
          inherit (prev.vimUtils) buildVimPlugin;
          plugins =
            builtins.filter
            (s: (builtins.match "plugin:.*" s) != null)
            (builtins.attrNames inputs);
          plugName = input:
            builtins.substring
            (builtins.stringLength "plugin:")
            (builtins.stringLength input)
            input;
          buildPlug = name:
            buildVimPlugin {
              pname = plugName name;
              version = "master";
              src = builtins.getAttr name inputs;
            };
        in {
          neovimPlugins = builtins.listToAttrs (map
            (plugin: {
              name = plugName plugin;
              value = buildPlug plugin;
            })
            plugins);
        };

        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            pluginOverlay
            neovim-nightly.overlay
          ];
        };

        allPluginsFromInputs = pkgs.lib.attrsets.mapAttrsToList (name: value: value) pkgs.neovimPlugins;

        customConfig = pkgs.neovimUtils.makeNeovimConfig {
          withPython3 = true;
          withNodeJs = false;
          customRC = ''
            lua << EOF
              vim.loader.enable()

              vim.g.mapleader = ' '
              vim.g.maplocalleader = ' '

              vim.opt.rtp:prepend("${./config}")
              vim.opt.packpath = vim.opt.rtp:get()
              require("_cfg")

              vim.filetype.add({
                extension = {
                  conf = 'config',
                  njk = 'htmldjango',
                  ['tsconfig*.json'] = 'jsonc',
                },
                filename = {
                  ['.luacheckrc'] = 'lua',
                  ['.eslintrc.json'] = 'jsonc',
                  ['.envrc'] = 'config',
                },
              })
            EOF
          '';

          plugins =
            allPluginsFromInputs
            ++ (with pkgs.vimPlugins; [
              # theme
              catppuccin-nvim
              # dependencies
              plenary-nvim
              nvim-web-devicons
              # langs/syntax
              nvim-treesitter
              # comments
              {
                plugin = comment-nvim;
                config = "lua require('Comment').setup({ ignore = '^$' })";
              }
              {
                plugin = nvim-ts-context-commentstring;
                config = "lua vim.g.skip_ts_context_commentstring_module = true";
              }
              # lint/format
              conform-nvim
              nvim-lint
              # lsp
              nvim-lspconfig
              lsp_signature-nvim
              hover-nvim
              {
                plugin = fidget-nvim;
                config = ''
                  lua << EOF
                    require('fidget').setup({
                      progress = { ignore_empty_message = false },
                    })
                  EOF
                '';
              }
              {
                plugin = glance-nvim;
                config = ''
                  lua << EOF
                    require('glance').setup({})
                    vim.keymap.set('n', 'gd', '<CMD>Glance definitions<CR>')
                    vim.keymap.set('n', 'gr', '<CMD>Glance references<CR>')
                    vim.keymap.set('n', 'gD', '<CMD>Glance type_definitions<CR>')
                    vim.keymap.set('n', 'gy', '<CMD>Glance implementations<CR>')
                  EOF
                '';
              }
              {
                plugin = nvim-code-action-menu;
                config = "nnoremap <f4> <cmd>CodeActionMenu<cr>";
              }
              {
                plugin = inc-rename-nvim;
                config = ''
                  lua << EOF
                    require('inc_rename').setup({input_buffer_type = 'dressing'})
                    vim.keymap.set("n", "<f2>", function()
                      return ":IncRename " .. vim.fn.expand("<cword>")
                    end, { expr = true })
                  EOF
                '';
              }
              # cmp
              nvim-cmp
              cmp-buffer
              cmp-async-path
              cmp-nvim-lsp
              lspkind-nvim
              nvim-snippy
              cmp-snippy
              # navigation
              telescope-nvim
              telescope-live-grep-args-nvim
              # misc
              {
                plugin = persistence-nvim;
                config = ''
                  lua << EOF
                    require('persistence').setup({ options = vim.opt.sessionoptions:get() })
                    vim.keymap.set('n', '<space>s', function()
                      require('persistence').load()
                    end)
                  EOF
                '';
              }
              {
                plugin = pkgs.neovimPlugins.vim-star;
                config = ''
                  lua << EOF
                    vim.keymap.set({'n','x'},'*', '<Plug>(star-*)')
                    vim.keymap.set({'n','x'},'gs', '<Plug>(star-*)cgn')
                  EOF
                '';
              }
              {
                plugin = nvim-surround;
                config = "lua require('nvim-surround').setup()";
              }
              {
                plugin = pkgs.neovimPlugins.auto-save;
                config = "lua require('auto-save').setup()";
              }
              dressing-nvim
              bigfile-nvim
              vim-repeat
              {
                plugin = pkgs.neovimPlugins.arrow;
                config = "lua require('arrow').setup({leader_key = '<f1>'})";
              }
              # quickfix
              nvim-bqf
              nvim-pqf
              # git
              gitsigns-nvim
              diffview-nvim
              neogit
            ]);
        };

        # Extra packages made available to nvim but not the system
        # system packages take precedence over these
        extraPkgsPath = pkgs.lib.makeBinPath (with pkgs; [
          # lsps
          nil
          lua-language-server
          # linters
          nodePackages_latest.jsonlint
          yamllint
          lua54Packages.luacheck
          statix
          # formatters
          shfmt
          stylua
          alejandra
          jq
          # dicts
          aspell
          aspellDicts.en
          # deps
          gcc
        ]);
      in rec {
        packages.nvim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped (customConfig
          // {
            wrapperArgs = customConfig.wrapperArgs ++ ["--suffix" "PATH" ":" extraPkgsPath];
          });
        defaultPackage = packages.nvim;
        apps.nvim = {
          type = "app";
          program = "${defaultPackage}/bin/nvim";
        };
        apps.default = apps.nvim;
      }
    );
}
