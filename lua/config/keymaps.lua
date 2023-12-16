-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
if vim.fn.executable("gitui") == 1 then
  -- gitui instead of lazygit
  vim.keymap.set("n", "<leader>gG", function() require("lazyvim.util").terminal.open({ "gitui" }, { esc_esc = false, ctrl_hjkl = false }) end, { desc = "gitui (cwd)" })
  vim.keymap.set("n", "<leader>gg", function() require("lazyvim.util").terminal.open({ "gitui" }, { cwd = require("lazyvim.util").root.get(), esc_esc = false, ctrl_hjkl = false }) end, { desc = "gitui (root dir)" })
end

if vim.fn.executable("btop") == 1 then
  -- btop
  vim.keymap.set("n", "<leader>xb", function() require("lazyvim.util").terminal.open({ "btop" }, { esc_esc = false, ctrl_hjkl = false }) end, { desc = "btop" })
end
