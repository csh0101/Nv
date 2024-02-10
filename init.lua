-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")({
  debug = false,
  defaults = {
    lazy = true,
    -- cond = false,
  },
  nv = {
    alpha = true,
    colorscheme = "onedark", -- colorscheme setting for either onedark.nvim or github-theme
    codeium_support = false, -- enable codeium extension
    copilot_support = true, -- enable copilot extension
    coverage_support = true, -- enable coverage extension
    dap_support = true, -- enable dap extension
    lang = {
      php = true,
      clangd = true, -- enable clangd and cmake extension
      docker = true, -- enable docker extension
      elixir = false, -- enable elixir extension
      go = true, -- enable go extension
      java = true, -- enable java extension
      nodejs = true, -- enable nodejs (typescript, css, html, json) extension
      python = true, -- enable python extension
      ruby = false, -- enable ruby extension
      rust = true, -- enable rust extension
      terraform = false, -- enable terraform extension
      tex = false, -- enable tex extension
      yaml = true, -- enable yaml extension
      flutter = false, -- enable flutter extension
      dart = false, -- enable dart extension
      typescript = true,
    },
    rest_support = true, -- enable rest.nvim extension
    test_support = true, -- enable test extension
  },
  performance = {
    cache = {
      enabled = true,
    },
  },
})
require("nvim-treesitter.install").prefer_git = true

local lspconfig = require("lspconfig")
local lspconfig_configs = require("lspconfig.configs")
local lspconfig_util = require("lspconfig.util")

local function on_new_config(new_config, new_root_dir)
  local function get_typescript_server_path(root_dir)
    local project_root = lspconfig_util.find_node_modules_ancestor(root_dir)
    return project_root
        and (lspconfig_util.path.join(project_root, "node_modules", "typescript", "lib", "tsserverlibrary.js"))
      or ""
  end

  if
    new_config.init_options
    and new_config.init_options.typescript
    and new_config.init_options.typescript.tsdk == ""
  then
    new_config.init_options.typescript.tsdk = get_typescript_server_path(new_root_dir)
  end
end

local volar_cmd = { "vue-language-server", "--stdio" }
local volar_root_dir = lspconfig_util.root_pattern("package.json")

lspconfig_configs.volar_api = {
  default_config = {
    cmd = volar_cmd,
    root_dir = volar_root_dir,
    on_new_config = on_new_config,
    filetypes = { "vue" },
    -- If you want to use Volar's Take Over Mode (if you know, you know)
    --filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'json' },
    init_options = {
      typescript = {
        tsdk = "",
      },
      languageFeatures = {
        implementation = true, -- new in @volar/vue-language-server v0.33
        references = true,
        definition = true,
        typeDefinition = true,
        callHierarchy = true,
        hover = true,
        rename = true,
        renameFileRefactoring = true,
        signatureHelp = true,
        codeAction = true,
        workspaceSymbol = true,
        completion = {
          defaultTagNameCase = "both",
          defaultAttrNameCase = "kebabCase",
          getDocumentNameCasesRequest = false,
          getDocumentSelectionRequest = false,
        },
      },
    },
  },
}
lspconfig.volar_api.setup({})

lspconfig_configs.volar_doc = {
  default_config = {
    cmd = volar_cmd,
    root_dir = volar_root_dir,
    on_new_config = on_new_config,

    filetypes = { "vue" },
    -- If you want to use Volar's Take Over Mode (if you know, you know):
    --filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'json' },
    init_options = {
      typescript = {
        tsdk = "",
      },
      languageFeatures = {
        implementation = true, -- new in @volar/vue-language-server v0.33
        documentHighlight = true,
        documentLink = true,
        codeLens = { showReferencesNotification = true },
        -- not supported - https://github.com/neovim/neovim/pull/15723
        semanticTokens = false,
        diagnostics = true,
        schemaRequestService = true,
      },
    },
  },
}
lspconfig.volar_doc.setup({})

lspconfig_configs.volar_html = {
  default_config = {
    cmd = volar_cmd,
    root_dir = volar_root_dir,
    on_new_config = on_new_config,

    filetypes = { "vue" },
    -- If you want to use Volar's Take Over Mode (if you know, you know), intentionally no 'json':
    --filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
    init_options = {
      typescript = {
        tsdk = "",
      },
      documentFeatures = {
        selectionRange = true,
        foldingRange = true,
        linkedEditingRange = true,
        documentSymbol = true,
        -- not supported - https://github.com/neovim/neovim/pull/13654
        documentColor = false,
        documentFormatting = {
          defaultPrintWidth = 100,
        },
      },
    },
  },
}
lspconfig.volar_html.setup({})

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
    if server_name == "volar" then
      server_config.filetypes = { "vue", "typescript", "javascript" }
    end
    if server_name == "lua_ls" then
      server_config.settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
        },
      }
    end
    lspconfig[server_name].setup(server_config)
  end,
})
