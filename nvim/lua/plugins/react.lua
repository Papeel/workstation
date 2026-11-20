return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "css", "scss", "html", "graphql" },
    },
  },
  {
    "L3MON4D3/LuaSnip",
    config = function(_, opts)
      require("luasnip").setup(opts)
      -- Snippets propios en lua/snippets/<filetype>/*.lua
      require("luasnip.loaders.from_lua").load({
        paths = { vim.fn.stdpath("config") .. "/lua/snippets" },
      })
      require("luasnip").filetype_extend("javascriptreact", { "react" })
      require("luasnip").filetype_extend("typescriptreact", { "react" })
    end,
  },
}
