return {
  {
    "neovim/nvim-lspconfig",
    ensure_installed = { "bash-language-server" },
    opts = {
      servers = {
        bashls = {},
      },
    },
  },
}
