-- Vendored plugins, loaded with :packadd. Each section notes what it replaces
-- from the old lazy.nvim setup.
local map = vim.keymap.set
local nerd = vim.g.have_nerd_font

local function add(name)
  local ok, err = pcall(vim.cmd.packadd, name)
  if not ok then
    vim.notify("packadd " .. name .. " failed: " .. tostring(err), vim.log.levels.ERROR)
  end
  return ok
end

local function setup(mod, opts)
  local ok, m = pcall(require, mod)
  if not ok then
    vim.notify("missing " .. mod, vim.log.levels.WARN)
    return nil
  end
  m.setup(opts or {})
  return m
end

-- ─── Colorscheme: tokyonight (night, transparent, your custom palette) ──────
if add("tokyonight.nvim") then
  local transparent = true
  require("tokyonight").setup({
    style = "night",
    transparent = transparent,
    styles = {
      sidebars = transparent and "transparent" or "dark",
      floats = transparent and "transparent" or "dark",
    },
    on_colors = function(c)
      c.bg = "#011628"
      c.bg_dark = transparent and c.none or "#011423"
      c.bg_float = transparent and c.none or "#011423"
      c.bg_highlight = "#143652"
      c.bg_popup = "#011423"
      c.bg_search = "#0A64AC"
      c.bg_sidebar = transparent and c.none or "#011423"
      c.bg_statusline = transparent and c.none or "#011423"
      c.bg_visual = "#275378"
      c.border = "#547998"
      c.fg = "#CBE0F0"
      c.fg_dark = "#B4D0E9"
      c.fg_float = "#CBE0F0"
      c.fg_gutter = "#627E97"
      c.fg_sidebar = "#B4D0E9"
    end,
  })
  vim.cmd.colorscheme("tokyonight")
else
  pcall(vim.cmd.colorscheme, "habamax")
end

if not add("mini.nvim") then
  return
end

-- ─── Icons (replaces nvim-web-devicons) ─────────────────────────────────────
setup("mini.icons", { style = nerd and "glyph" or "ascii" })
MiniIcons.mock_nvim_web_devicons() -- nvim-tree picks these up

-- ─── UI: statusline, buffer tabs, start screen ──────────────────────────────
-- replaces lualine, bufferline, alpha
setup("mini.statusline", { use_icons = nerd })
setup("mini.tabline", { show_icons = nerd })
local starter = require("mini.starter")
starter.setup({
  header = table.concat({
    "██╗  ██╗ ██████╗ ██████╗  ██████╗ ",
    "██║  ██║██╔═══██╗██╔══██╗██╔═══██╗",
    "███████║██║   ██║██████╔╝██║   ██║",
    "██╔══██║██║   ██║██╔══██╗██║   ██║",
    "██║  ██║╚██████╔╝██████╔╝╚██████╔╝",
    "╚═╝  ╚═╝ ╚═════╝ ╚═════╝  ╚═════╝ ",
  }, "\n"),
  items = {
    starter.sections.sessions(5, true),
    starter.sections.recent_files(8, true, false),
    starter.sections.builtin_actions(),
  },
  footer = "",
})
setup("mini.notify")
vim.notify = MiniNotify.make_notify()

-- ─── Editing (replaces autopairs, nvim-surround, comment, treesitter-textobjects)
setup("mini.pairs")
setup("mini.ai", { n_lines = 500 }) -- af/if function, ac/ic class, aa/ia arg, etc.
setup("mini.surround", { -- tpope-style mappings, same as your old nvim-surround
  mappings = {
    add = "ys", delete = "ds", replace = "cs",
    find = "", find_left = "", highlight = "",
    suffix_last = "", suffix_next = "",
  },
  search_method = "cover_or_next",
})
pcall(vim.keymap.del, "x", "ys")
map("x", "S", [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true, desc = "Surround selection" })
map("n", "yss", "ys_", { remap = true, desc = "Surround line" })
-- Commenting: built into nvim >= 0.10 (gc / gcc), no plugin needed.
setup("mini.move") -- Alt-hjkl moves lines/selections
setup("mini.bufremove")
map("n", "<leader>bd", function() MiniBufremove.delete() end, { desc = "Delete buffer (keep split)" })

-- ─── Visual aids (replaces indent-blankline, todo-comments highlight) ───────
setup("mini.indentscope", { symbol = "│", draw = { delay = 50 } })
local hipatterns = require("mini.hipatterns")
hipatterns.setup({
  highlighters = {
    fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
    hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
    todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
    note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
})
setup("mini.trailspace")

-- ─── Git (replaces gitsigns) — shells out to local git, no network ──────────
setup("mini.git")
setup("mini.diff", { view = { style = "sign" } })
map("n", "<leader>go", function() MiniDiff.toggle_overlay() end, { desc = "Toggle diff overlay" })
map("n", "<leader>gb", "<cmd>vert Git blame -- %<CR>", { desc = "Git blame (split)" })
-- Hunks: ]h / [h navigate, gh{motion} apply (stage), gH{motion} reset.

-- ─── Sessions (replaces auto-session) ───────────────────────────────────────
local util = require("hobo.util")
setup("mini.sessions", { autoread = false, autowrite = true })
map("n", "<leader>ws", function() MiniSessions.write(util.session_name()) end, { desc = "Save session for cwd" })
map("n", "<leader>wr", function() MiniSessions.read(util.session_name()) end, { desc = "Restore session for cwd" })
map("n", "<leader>wl", function() MiniSessions.select() end, { desc = "List sessions" })

-- ─── Fuzzy finding (replaces telescope + fzf-native) ────────────────────────
-- Uses rg/fd if installed, falls back to git ls-files / vim's own search.
setup("mini.pick", {
  mappings = { move_down = "<C-j>", move_up = "<C-k>" }, -- your telescope maps
  window = { config = { border = "rounded" } },
})
setup("mini.extra")
vim.ui.select = MiniPick.ui_select
local P, X = MiniPick.builtin, MiniExtra.pickers
-- Files incl. dotfiles (rg/default pickers skip hidden), still honoring .gitignore
local function find_files()
  if vim.fn.executable("rg") == 0 then return P.files() end
  MiniPick.builtin.cli({ command = { "rg", "--files", "--hidden", "--color=never", "-g", "!.git" } }, {
    source = {
      name = "Files",
      show = function(buf, items, query) MiniPick.default_show(buf, items, query, { show_icons = true }) end,
    },
  })
end
map("n", "<leader>ff", find_files, { desc = "Find files (incl. hidden)" })
map("n", "<leader>fr", function() X.oldfiles() end, { desc = "Recent files" })
map("n", "<leader>fs", function() P.grep_live() end, { desc = "Live grep" })
map("n", "<leader>fc", function() P.grep({ pattern = vim.fn.expand("<cword>") }) end, { desc = "Grep word under cursor" })
map("n", "<leader>ft", function() P.grep({ pattern = [[\b(TODO|FIXME|HACK|NOTE)\b]] }) end, { desc = "Find TODOs" })
map("n", "<leader>fb", function() P.buffers() end, { desc = "Buffers" })
map("n", "<leader>fh", function() P.help() end, { desc = "Help tags" })
map("n", "<leader>fk", function() X.keymaps() end, { desc = "Search keymaps" })
map("n", "<leader>fd", function() X.diagnostic() end, { desc = "Diagnostics (workspace)" })
map("n", "<leader>fg", function() X.git_hunks() end, { desc = "Git hunks" })
map("n", "<leader>f/", function() X.buf_lines({ scope = "current" }) end, { desc = "Lines in buffer" })
map("n", "<leader>f:", function() X.history({ scope = ":" }) end, { desc = "Command history" })
map("n", "<leader>fR", function() P.resume() end, { desc = "Resume last picker" })

-- ─── Completion (replaces nvim-cmp) ─────────────────────────────────────────
-- LSP completion when a server is attached, buffer words otherwise.
setup("mini.completion")
local pum = function(yes, no)
  return function() return vim.fn.pumvisible() == 1 and yes or no end
end
map("i", "<C-j>", pum("<C-n>", "<C-j>"), { expr = true, desc = "Next completion" })
map("i", "<C-k>", pum("<C-p>", "<C-k>"), { expr = true, desc = "Prev completion" })
map("i", "<Tab>", pum("<C-n>", "<Tab>"), { expr = true, desc = "Next completion" })
map("i", "<S-Tab>", pum("<C-p>", "<S-Tab>"), { expr = true, desc = "Prev completion" })

-- ─── File tree (nvim-tree, same keys as before) ─────────────────────────────
if add("nvim-tree.lua") then
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1
  require("nvim-tree").setup({
    view = { width = 35, relativenumber = true },
    renderer = {
      indent_markers = { enable = true },
      icons = {
        show = { file = nerd, folder = nerd, folder_arrow = true, git = nerd },
        glyphs = nerd and { folder = { arrow_closed = "", arrow_open = "" } }
          or { folder = { arrow_closed = ">", arrow_open = "v" } },
      },
    },
    actions = { open_file = { window_picker = { enable = false } } },
    filters = { custom = { ".DS_Store" } },
    git = { ignore = false },
  })
  map("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree" })
  map("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "File tree at current file" })
  map("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file tree" })
  map("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file tree" })
  -- Inside the tree: g? shows all tree keys.
end

-- ─── Treesitter highlighting: built-in only ─────────────────────────────────
-- nvim bundles parsers for lua, vim, vimdoc, c, query, markdown (and a few
-- more by version). Other languages fall back to regex syntax. Drop extra
-- compiled parsers (*.so) into ~/.config/nvim/parser/ to add languages.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("hobo_ts", { clear = true }),
  callback = function(ev)
    pcall(vim.treesitter.start, ev.buf)
  end,
})

-- ─── Keybind discovery (replaces which-key) ─────────────────────────────────
-- Press <Space> (or g, z, [, ], <C-w>, ", ') and pause: a panel lists what
-- comes next. <Space>fk fuzzy-searches every mapping with its description.
local clue = require("mini.clue")
clue.setup({
  triggers = {
    { mode = "n", keys = "<Leader>" }, { mode = "x", keys = "<Leader>" },
    { mode = "n", keys = "g" }, { mode = "x", keys = "g" },
    { mode = "n", keys = "z" }, { mode = "x", keys = "z" },
    { mode = "n", keys = "[" }, { mode = "n", keys = "]" },
    { mode = "n", keys = "<C-w>" },
    { mode = "n", keys = "'" }, { mode = "n", keys = "`" },
    { mode = "n", keys = '"' }, { mode = "x", keys = '"' },
    { mode = "i", keys = "<C-r>" }, { mode = "c", keys = "<C-r>" },
    { mode = "i", keys = "<C-x>" },
  },
  clues = {
    { mode = "n", keys = "<Leader>b", desc = "+Buffer" },
    { mode = "n", keys = "<Leader>c", desc = "+Code (LSP)" },
    { mode = "n", keys = "<Leader>e", desc = "+Explorer" },
    { mode = "n", keys = "<Leader>f", desc = "+Find" },
    { mode = "n", keys = "<Leader>g", desc = "+Git" },
    { mode = "n", keys = "<Leader>l", desc = "+LazyGit" },
    { mode = "n", keys = "<Leader>m", desc = "+Format" },
    { mode = "n", keys = "<Leader>r", desc = "+Rename/Restart" },
    { mode = "n", keys = "<Leader>s", desc = "+Splits" },
    { mode = "n", keys = "<Leader>t", desc = "+Tabs" },
    { mode = "n", keys = "<Leader>T", desc = "+Terminal" },
    { mode = "n", keys = "<Leader>w", desc = "+Session" },
    clue.gen_clues.builtin_completion(),
    clue.gen_clues.g(),
    clue.gen_clues.marks(),
    clue.gen_clues.registers(),
    clue.gen_clues.square_brackets(),
    clue.gen_clues.windows({ submode_resize = true }),
    clue.gen_clues.z(),
  },
  window = { delay = 300, config = { width = "auto", border = "rounded" } },
})
