return {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
  root_markers = { ".git" },
  settings = {
    yaml = { keyOrdering = false, format = { enable = true } },
    redhat = { telemetry = { enabled = false } },
  },
}
