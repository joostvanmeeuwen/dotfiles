return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        dockerls = {},
      },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "dockerfile-language-server",
      })
    end,
  },
}
