return {
  diagnostics = {
    disable = { 'unnecessary-if' },
  },
  workspace = {
    library = {
      '$VIMRUNTIME',
      '$XDG_DATA_HOME/nvim/site/pack/pckr/opt',
      '$HOME/projects/nvim-treesitter-context',
      '$HOME/projects/pckr.nvim',
    },
  },
}
