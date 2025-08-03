return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      for _, plugin in ipairs(require("lazy").plugins()) do
        if plugin.ensure_installed then
          vim.list_extend(opts.ensure_installed, plugin.ensure_installed)
        end
      end
    end,
  },
}
