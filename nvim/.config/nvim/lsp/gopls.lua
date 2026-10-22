return {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.work", "go.mod", ".git" },
  settings = {
    gopls = {
      staticcheck = true,
      analyses = { unusedparams = true, shadow = true },
      hints = { parameterNames = true, assignVariableTypes = true, compositeLiteralFields = true },
    },
  },
}
