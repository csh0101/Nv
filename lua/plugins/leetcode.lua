return {
  "Dhanus3133/LeetBuddy.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    require("leetbuddy").setup({
      domain = "cn",
      language = "go",
    })
  end,
  keys = {
    { "<leader>Gq", "<cmd>LBQuestions<cr>", desc = "List Questions" },
    { "<leader>Gl", "<cmd>LBQuestion<cr>", desc = "View Question" },
    { "<leader>Gr", "<cmd>LBReset<cr>", desc = "Reset Code" },
    { "<leader>Gt", "<cmd>LBTest<cr>", desc = "Run Code" },
    { "<leader>Gs", "<cmd>LBSubmit<cr>", desc = "Submit Code" },
  },
}
