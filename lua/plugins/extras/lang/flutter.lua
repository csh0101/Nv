return {
  "akinsho/flutter-tools.nvim",
  lazy = true,
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("flutter-tools").setup({})
  end,
}
