-- hobo's nvim — offline by design.
--
-- No plugin manager, no git, no network at runtime. Plugins are vendored as
-- plain files under pack/vendor/opt/ and loaded with :packadd (see
-- VENDORED.md; refresh with ./vendor.sh from the repo root on a personal box).
--
--   nvim >= 0.11  everything
--   nvim  = 0.10  everything; LSP via a small compat shim
--   nvim  < 0.10  options + keymaps only, built-in colorscheme, no plugins
--
-- Keybind help: press <Space> and wait, or <Space>fk to search every keymap.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Icons: glyphs need a Nerd Font in the terminal. Set NVIM_ASCII=1 (or
-- vim.g.have_nerd_font = false in lua/local.lua) on boxes without one.
vim.g.have_nerd_font = vim.env.NVIM_ASCII ~= "1"

-- Machine-local overrides, loaded first so they can flip globals above.
-- lua/local.lua is gitignored; see lua/local.lua.example.
do
  local ok, err = pcall(require, "local")
  if not ok and not tostring(err):match("module 'local' not found") then
    vim.notify("lua/local.lua: " .. tostring(err), vim.log.levels.ERROR)
  end
end

require("hobo.options")
require("hobo.keymaps")

if vim.fn.has("nvim-0.10") == 1 then
  require("hobo.plugins")
  require("hobo.lsp")
else
  pcall(vim.cmd.colorscheme, "habamax")
  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      vim.notify("nvim < 0.10: plugins and LSP disabled (basic config only)", vim.log.levels.WARN)
    end,
  })
end
