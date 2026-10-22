-- LSP without mason or nvim-lspconfig.
--
-- Server definitions live in ../../lsp/<name>.lua (nvim 0.11's native format).
-- A server is enabled only if its binary is on PATH, so install whichever
-- you need from distro packages / go install / npm and it just lights up.
-- Check status with :checkhealth vim.lsp
local servers = {
  "gopls", "lua_ls", "pyright", "ruff", "bashls", "terraformls",
  "yamlls", "jsonls", "marksman", "clangd", "rust_analyzer",
}

-- Filetypes that format (and for Go, organize imports) on save.
vim.g.format_on_save = vim.g.format_on_save
  or { go = true, terraform = true, ["terraform-vars"] = true, rust = true }

local nerd = vim.g.have_nerd_font
local has011 = vim.fn.has("nvim-0.11") == 1
local map = vim.keymap.set

-- ─── Diagnostics ────────────────────────────────────────────────────────────
local S = vim.diagnostic.severity
vim.diagnostic.config({
  severity_sort = true,
  virtual_text = { spacing = 2, source = "if_many" },
  float = { border = "rounded", source = true },
  signs = {
    text = nerd and { [S.ERROR] = " ", [S.WARN] = " ", [S.INFO] = " ", [S.HINT] = "󰠠 " }
      or { [S.ERROR] = "E", [S.WARN] = "W", [S.INFO] = "I", [S.HINT] = "H" },
  },
})

-- ─── Helpers ────────────────────────────────────────────────────────────────
local function pick_lsp(scope)
  return function()
    if MiniExtra then
      MiniExtra.pickers.lsp({ scope = scope })
    else
      vim.lsp.buf[scope]()
    end
  end
end

local function restart()
  if vim.fn.exists(":lsp") == 2 then -- nvim >= 0.12
    vim.cmd("lsp restart")
    return
  end
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    c.stop(c)
  end
  vim.defer_fn(function() vim.cmd("edit") end, 300)
end

local function organize_imports(client, buf)
  local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
  params.context = { only = { "source.organizeImports" }, diagnostics = {} }
  local res = vim.lsp.buf_request_sync(buf, "textDocument/codeAction", params, 1000)
  for _, r in pairs(res or {}) do
    for _, action in pairs(r.result or {}) do
      if action.edit then
        vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
      end
    end
  end
end

-- ─── Per-buffer setup when a server attaches ────────────────────────────────
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("hobo_lsp", { clear = true }),
  callback = function(ev)
    local buf = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local o = function(desc) return { buffer = buf, silent = true, desc = desc } end

    -- Same keys as the old telescope/lspconfig setup
    map("n", "gR", pick_lsp("references"), o("LSP references"))
    map("n", "gD", vim.lsp.buf.declaration, o("Go to declaration"))
    map("n", "gd", pick_lsp("definition"), o("Go to definition"))
    map("n", "gi", pick_lsp("implementation"), o("Go to implementation"))
    map("n", "gt", pick_lsp("type_definition"), o("Go to type definition"))
    map("n", "K", vim.lsp.buf.hover, o("Hover docs"))
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, o("Code action"))
    map("n", "<leader>rn", vim.lsp.buf.rename, o("Rename symbol"))
    map("n", "<leader>D", function()
      if MiniExtra then MiniExtra.pickers.diagnostic({ scope = "current" }) else vim.diagnostic.setloclist() end
    end, o("Buffer diagnostics"))
    map("n", "<leader>rs", restart, o("Restart LSP"))
    map("n", "<leader>cs", pick_lsp("document_symbol"), o("Document symbols"))
    map("n", "<leader>cS", pick_lsp("workspace_symbol"), o("Workspace symbols"))
    map({ "n", "v" }, "<leader>mp", function() vim.lsp.buf.format({ timeout_ms = 2000 }) end, o("Format"))

    if client and has011 and client:supports_method("textDocument/inlayHint") then
      map("n", "<leader>ch", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
      end, o("Toggle inlay hints"))
    end

    local ft = vim.bo[buf].filetype
    if client and vim.g.format_on_save[ft] and client.server_capabilities.documentFormattingProvider then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = buf,
        group = vim.api.nvim_create_augroup("hobo_fmt_" .. buf, { clear = true }),
        callback = function()
          if ft == "go" then organize_imports(client, buf) end
          vim.lsp.buf.format({ bufnr = buf, id = client.id, timeout_ms = 2000 })
        end,
      })
    end
  end,
})

-- ─── Enable servers that are installed ──────────────────────────────────────
local caps = MiniCompletion and MiniCompletion.get_lsp_capabilities() or nil

if has011 then
  if caps then vim.lsp.config("*", { capabilities = caps }) end
  for _, name in ipairs(servers) do
    local cfg = vim.lsp.config[name]
    if cfg and type(cfg.cmd) == "table" and vim.fn.executable(cfg.cmd[1]) == 1 then
      vim.lsp.enable(name)
    end
  end
else
  -- nvim 0.10 shim: same lsp/*.lua files, started via vim.lsp.start.
  for _, name in ipairs(servers) do
    local file = vim.api.nvim_get_runtime_file("lsp/" .. name .. ".lua", false)[1]
    local ok, cfg = pcall(dofile, file or "")
    if ok and type(cfg) == "table" and vim.fn.executable(cfg.cmd[1]) == 1 then
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("hobo_lsp_" .. name, { clear = true }),
        pattern = cfg.filetypes,
        callback = function(ev)
          vim.lsp.start({
            name = name,
            cmd = cfg.cmd,
            root_dir = vim.fs.root(ev.buf, cfg.root_markers or { ".git" }) or vim.fn.getcwd(),
            settings = cfg.settings,
            init_options = cfg.init_options,
            capabilities = caps,
          })
        end,
      })
    end
  end
end
