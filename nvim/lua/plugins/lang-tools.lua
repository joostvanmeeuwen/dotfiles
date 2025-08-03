return {
  {
    "neovim/nvim-lspconfig",
    ensure_installed = { "dockerfile-language-server" },
    opts = {
      servers = {
        dockerls = {},
      },
    },
  },
}
