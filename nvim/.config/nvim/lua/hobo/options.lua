local opt = vim.opt

-- netrw stays usable as a fallback tree (nvim-tree disables it when loaded)
vim.g.netrw_liststyle = 3
vim.g.netrw_banner = 0

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.mouse = "a"
opt.showmode = false -- statusline shows it

-- tabs & indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- search
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split" -- live preview of :s

-- splits
opt.splitright = true
opt.splitbelow = true

-- files
opt.swapfile = false
opt.undofile = true -- persistent undo in stdpath("state")
opt.updatetime = 250
opt.timeoutlen = 400 -- also how long before mini.clue pops up

opt.background = "dark"
opt.backspace = "indent,eol,start"
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.completeopt = { "menuone", "noselect", "noinsert" }
opt.pumheight = 12

-- Clipboard: deferred so a slow provider check doesn't stall startup.
-- Over SSH, nvim >= 0.10 uses OSC52 automatically (works through tmux with
-- set-clipboard on).
vim.schedule(function()
  opt.clipboard:append("unnamedplus")
end)

-- nvim guesses .tf as TinyFugue unless the file already looks like HCL.
vim.filetype.add({ extension = { tf = "terraform" } })

-- Briefly highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("hobo_yank", { clear = true }),
  callback = function()
    (vim.hl or vim.highlight).on_yank({ timeout = 150 })
  end,
})
