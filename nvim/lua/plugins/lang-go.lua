return {
  {
    "neovim/nvim-lspconfig",
    ensure_installed = { "gopls", "delve" },
    opts = {
      servers = {
        gopls = {},
      },
    },
  },
}
