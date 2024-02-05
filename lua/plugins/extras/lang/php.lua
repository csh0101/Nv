return {
  {
    "gbprod/phpactor.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required to update phpactor
      "neovim/nvim-lspconfig", -- required to automaticly register lsp serveur
      -- {
      --   "hrsh7th/nvim-cmp",
      --   event = { "BufRead *.php" },
      --   config = true,
      -- },
    },
    config = function()
      lspconfig = require("lspconfig")
      lspconfig.phpactor.setup({})
      lspconfig.intelephense.setup({})
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        print("php need to set in nvim-treesitter")
        vim.list_extend(opts.ensure_installed, { "php", "php_only", "phpdoc" })
      end
    end,
  },

  -- correctly setup mason lsp extensions
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        print("phpactor ensure_installed")
        vim.list_extend(opts.ensure_installed, { "phpactor", "intelephense" })
      end
    end,
  },
}
