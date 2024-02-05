-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
if vim.fn.executable("gitui") == 1 then
  -- gitui instead of lazygit
  vim.keymap.set("n", "<leader>gG", function()
    require("lazyvim.util").float_term({ "gitui" }, { esc_esc = false, ctrl_hjkl = false })
  end, { desc = "gitui (cwd)" })
  vim.keymap.set("n", "<leader>gg", function()
    require("lazyvim.util").float_term(
      { "gitui" },
      { cwd = require("lazyvim.util").get_root(), esc_esc = false, ctrl_hjkl = false }
    )
  end, { desc = "gitui (root dir)" })
end

if vim.fn.executable("btop") == 1 then
  -- btop
  vim.keymap.set("n", "<leader>xb", function()
    require("lazyvim.util").float_term({ "btop" }, { esc_esc = false, ctrl_hjkl = false })
  end, { desc = "btop" })
end
vim.keymap.set("i", "jk", "<Esc>", { noremap = true })

-- vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
-- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
-- vim.keymap.set('n', ']Hd', vim.diagnostic.goto_next)
-- vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)
-- this is not work under the te
-- vim.keymap.set("t", "jk", "<esc><esc>", { noremap = true })

-- lsp global config

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    -- 声明
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    -- 定义
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    -- 光标详细信息，其实就是点击
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    -- 实现类
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    --
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
    --
    vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set("n", "<space>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<space>cg", function()
      vim.lsp.buf.format({ async = true })
    end, opts)
  end,
})
-- choice --

vim.api.nvim_set_keymap("i", "<C-n>", '<Cmd>lua require("luasnip").change_choice(1)<CR>', { silent = true })
vim.api.nvim_set_keymap("s", "<C-n>", '<Cmd>lua require("luasnip").change_choice(1)<CR>', { silent = true })
vim.api.nvim_set_keymap("i", "<C-n>", '<Cmd>lua require("luasnip").change_choice(-1)<CR>', { silent = true })
vim.api.nvim_set_keymap("s", "<C-n>", '<Cmd>lua require("luasnip").change_choice(-1)<CR>', { silent = true })

-- sh nvim language server --
vim.api.nvim_create_autocmd("FileType", {
  pattern = "sh",
  callback = function()
    vim.lsp.start({
      name = "bash-language-server",
      cmd = { "bash-language-server", "start" },
    })
  end,
})
