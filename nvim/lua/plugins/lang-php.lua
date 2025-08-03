return {
  {
    "neovim/nvim-lspconfig",
    ensure_installed = {
      "intelephense",
      "php-cs-fixer",
      "php-debug-adapter",
    },
    opts = {
      servers = {
        intelephense = {},
      },
    },
  },
}
