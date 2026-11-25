-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Salir del modo insert con jk
vim.keymap.set("i", "jk", "<Esc>", { desc = "Salir del modo insert con jk" })
