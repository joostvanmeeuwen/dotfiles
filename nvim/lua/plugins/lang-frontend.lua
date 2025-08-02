return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tsserver = {},
        html = {},
      },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "typescript-language-server",
        "prettierd",
        "eslint_d", 
      })
    end,
  },
}
