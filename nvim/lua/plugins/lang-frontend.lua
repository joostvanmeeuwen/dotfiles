return {
  {
    "neovim/nvim-lspconfig",
    ensure_installed = {
      "typescript-language-server",
      "prettierd",
      "eslint_d",
    },
    opts = {
      servers = {
        tsserver = {},
        html = {},
      },
    },
  },
}
