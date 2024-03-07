local function setup()
  local metals = require('metals')

  metals.initialize_or_attach(vim.tbl_deep_extend('force', metals.bare_config(), {
    handlers = {
      ['metals/status'] = function(_, status, ctx)
        vim.lsp.handlers['$/progress'](_, {
          token = 1,
          value = {
            kind = status.show and 'begin' or status.hide and 'end' or 'report',
            message = status.text,
          },
        }, ctx)
      end,
    },

    init_options = {
      statusBarProvider = 'on',
    },
    settings = {
      showInferredType = true,
      showImplicitArguments = true,
      enableSemanticHighlighting = true,
    },
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
  }))
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'scala', 'sbt' },
  callback = setup,
})
