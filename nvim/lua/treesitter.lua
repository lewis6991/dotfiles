require'nvim-treesitter.configs'.setup {
  ensure_installed = {
      "scala",
      "python",
      "yaml",
      "json",
      "html",
      "bash",
      "markdown",
      "rst"
  },
  highlight = {
    enable = true,
  },
}
