-- Core keymaps (no plugins needed). Plugin and LSP maps live in plugins.lua
-- and lsp.lua. Every map has a desc so it shows in <Space>fk and mini.clue.
local map = vim.keymap.set
local util = require("hobo.util")

map("i", "jk", "<Esc>", { desc = "Exit insert mode" })
map("n", "<leader>nh", "<cmd>nohl<CR>", { desc = "Clear search highlights" })
map("n", "<Esc>", "<cmd>nohl<CR><Esc>", { desc = "Clear search highlights" })

map("n", "<leader>+", "<C-a>", { desc = "Increment number" })
map("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

-- Splits (<leader>s)
map("n", "<leader>sv", "<C-w>v", { desc = "Split vertically" })
map("n", "<leader>sh", "<C-w>s", { desc = "Split horizontally" })
map("n", "<leader>se", "<C-w>=", { desc = "Equalize splits" })
map("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close split" })
map("n", "<leader>sm", util.toggle_maximize, { desc = "Maximize/restore split" })

-- Move between splits
map("n", "<C-h>", "<C-w>h", { desc = "Go to left split" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower split" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper split" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right split" })
-- Resize splits
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Taller split" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Shorter split" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Narrower split" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Wider split" })

-- Tabs (<leader>t)
map("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
map("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close tab" })
map("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Next tab" })
map("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Previous tab" })
map("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open buffer in new tab" })

-- Buffers (<leader>b)
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })

-- Terminal (<leader>T)
map("n", "<leader>Tt", util.float_term, { desc = "Floating terminal" })
map("n", "<leader>Ts", "<cmd>belowright 12split | terminal<CR>", { desc = "Terminal in split" })
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Leave terminal mode" })

-- Git
map("n", "<leader>lg", util.lazygit, { desc = "LazyGit (float)" })

-- Diagnostics (work with or without LSP)
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Prev diagnostic" })
map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic" })
if not vim.diagnostic.jump then -- nvim 0.10
  map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
  map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
end

-- Fallback file tree when plugins are unavailable (nvim < 0.10)
if vim.fn.has("nvim-0.10") == 0 then
  map("n", "<leader>ee", "<cmd>Lexplore<CR>", { desc = "Toggle file tree (netrw)" })
end
