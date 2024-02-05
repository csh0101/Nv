return {

  {
    "folke/neodev.nvim",
    opts = {},
    config = function()
      require("neodev").setup({
        override = function(_, library)
          library.enabled = true
          library.plugins = true
        end,
        pathStrict = false,
        -- lspconfig  = true
      })
    end,
  },

  { "folke/neoconf.nvim", cmd = "Neoconf", config = true, dependencies = { "nvim-lspconfig" } },

  -- uncomment and add lsp servers with their config to servers below
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      inlay_hints = { enabled = vim.fn.has("nvim-0.10") },
      ---@type lspconfig.options
    },
    config = function()
      require("neodev").setup({
        override = function(_, library)
          library.enabled = true
          library.plugins = true
        end,
        pathStrict = false,
        -- lspconfig  = true
      })
      require("mason").setup({})
      require("mason-lspconfig").setup({})
      local lspconfig = require("lspconfig")

      lspconfig.util.on_setup = lspconfig.util.add_hook_after(lspconfig.util.on_setup, function(config)
        if config.name == "lua_ls" then
          -- workaround for nvim's incorrect handling of scopes in the workspace/configuration handler
          -- https://github.com/folke/neodev.nvim/issues/41
          -- https://github.com/LuaLS/lua-language-server/issues/1089
          -- https://github.com/LuaLS/lua-language-server/issues/1596
          config.handlers = vim.tbl_extend("error", {}, config.handlers)
          config.handlers["workspace/configuration"] = function(...)
            local _, result, ctx = ...
            local client_id = ctx.client_id
            local client = vim.lsp.get_client_by_id(client_id)
            if client and client.workspace_folders and #client.workspace_folders then
              if result.items and #result.items > 0 then
                if not result.items[1].scopeUri then
                  return vim.tbl_map(function(_)
                    return nil
                  end, result.items)
                end
              end
            end

            return vim.lsp.handlers["workspace/configuration"](...)
          end
        end
      end)
      require("mason-lspconfig").setup_handlers({
        function(server_name)
          local server_config = {}
          if require("neoconf").get(server_name .. ".disable") then
            print(require("neoconf").get(server_name .. ".disable"))
            return
          end
          print(server_name)
          if server_name == "volar" then
            server_config.filetypes = { "vue", "typescript", "javascript" }
          end
          if server_name == "lua_ls" then
            print("good configure")
            server_config.settings = {
              Lua = {
                diagnostics = {
                  globals = { "vim" },
                },
              },
            }
          end
          -- if server_name == "html" then
          --   print("configurate html autocomplete for vue")
          --   server_config.filetypes = { "html", "vue" }
          -- end
          lspconfig[server_name].setup(server_config)
        end,
      })
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
  },

  -- uncomment and add tools to ensure_installed below
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(
        opts.ensure_installed,
        { "lua-language-server", "marksman", "vue-language-server", "typescript-language-server" }
      )
      opts.ui = {
        icons = {
          package_installed = "✓",
          package_pending = "",
          package_uninstalled = "✗",
        },
      }
    end,
  },

  -- disable the fancy UI for the debugger
  { "rcarriga/nvim-dap-ui", enabled = false },

  -- which key integration
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["<leader>dw"] = { name = "+widgets" },
      },
    },
  },

  -- dap integration
  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<leader>de",
        function()
          require("dap.ui.widgets").centered_float(require("dap.ui.widgets").expression, { border = "none" })
        end,
        desc = "Eval",
        mode = { "n", "v" },
      },
      {
        "<leader>dwf",
        function()
          require("dap.ui.widgets").centered_float(require("dap.ui.widgets").frames, { border = "none" })
        end,
        desc = "Frames",
      },
      {
        "<leader>dws",
        function()
          require("dap.ui.widgets").centered_float(require("dap.ui.widgets").scopes, { border = "none" })
        end,
        desc = "Scopes",
      },
      {
        "<leader>dwt",
        function()
          require("dap.ui.widgets").centered_float(require("dap.ui.widgets").threads, { border = "none" })
        end,
        desc = "Threads",
      },
    },
    opts = function(_, opts)
      require("dap").defaults.fallback.terminal_win_cmd = "enew | set filetype=dap-terminal"
    end,
  },

  -- overwrite Rust tools inlay hints
  {
    "simrat39/rust-tools.nvim",
    optional = true,
    opts = {
      tools = {
        inlay_hints = {
          -- nvim >= 0.10 has native inlay hint support,
          -- so we don't need the rust-tools specific implementation any longer
          auto = not vim.fn.has("nvim-0.10"),
        },
      },
    },
  },

  -- overwrite Jdtls options
  {
    "mfussenegger/nvim-jdtls",
    optional = true,
    opts = {
      settings = {
        java = {
          configuration = {
            updateBuildConfiguration = "automatic",
          },
          codeGeneration = {
            toString = {
              template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
            },
            useBlocks = true,
          },
          completion = {
            favoriteStaticMembers = {
              "org.assertj.core.api.Assertions.*",
              "org.junit.Assert.*",
              "org.junit.Assume.*",
              "org.junit.jupiter.api.Assertions.*",
              "org.junit.jupiter.api.Assumptions.*",
              "org.junit.jupiter.api.DynamicContainer.*",
              "org.junit.jupiter.api.DynamicTest.*",
              "org.mockito.Mockito.*",
              "org.mockito.ArgumentMatchers.*",
              "org.mockito.Answers.*",
            },
            importOrder = {
              "#",
              "java",
              "javax",
              "org",
              "com",
            },
          },
          contentProvider = { preferred = "fernflower" },
          eclipse = {
            downloadSources = true,
          },
          flags = {
            allow_incremental_sync = true,
            server_side_fuzzy_completion = true,
          },
          implementationsCodeLens = {
            enabled = false, --Don"t automatically show implementations
          },
          inlayHints = {
            parameterNames = { enabled = "all" },
          },
          maven = {
            downloadSources = true,
          },
          referencesCodeLens = {
            enabled = false, --Don"t automatically show references
          },
          references = {
            includeDecompiledSources = true,
          },
          saveActions = {
            organizeImports = true,
          },
          signatureHelp = { enabled = true },
          sources = {
            organizeImports = {
              starThreshold = 9999,
              staticStarThreshold = 9999,
            },
          },
        },
      },
    },
    config = function() end,
  },
}
