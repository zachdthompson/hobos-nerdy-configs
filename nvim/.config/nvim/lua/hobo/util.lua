local M = {}

-- Toggle "maximize current split" (replaces vim-maximizer).
function M.toggle_maximize()
  if vim.t.hobo_restore then
    vim.cmd(vim.t.hobo_restore)
    vim.t.hobo_restore = nil
  elseif vim.fn.winnr("$") > 1 then
    vim.t.hobo_restore = vim.fn.winrestcmd()
    vim.cmd("wincmd |")
    vim.cmd("wincmd _")
  end
end

-- Floating terminal. With a cmd, the float closes when the process exits.
function M.float_term(cmd)
  local w = math.floor(vim.o.columns * 0.9)
  local h = math.floor(vim.o.lines * 0.85)
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = w,
    height = h,
    col = math.floor((vim.o.columns - w) / 2),
    row = math.floor((vim.o.lines - h) / 2),
    style = "minimal",
    border = "rounded",
  })
  local on_exit = function()
    if cmd and vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  local job = cmd or vim.o.shell
  if vim.fn.has("nvim-0.11") == 1 then
    vim.fn.jobstart(job, { term = true, on_exit = on_exit })
  else
    vim.fn.termopen(job, { on_exit = on_exit })
  end
  vim.cmd.startinsert()
end

function M.lazygit()
  if vim.fn.executable("lazygit") == 0 then
    vim.notify("lazygit not installed", vim.log.levels.WARN)
    return
  end
  M.float_term("lazygit")
end

-- Per-directory session name for mini.sessions
function M.session_name()
  return (vim.fn.getcwd():gsub("[/\\:]", "%%")) .. ".vim"
end

return M
