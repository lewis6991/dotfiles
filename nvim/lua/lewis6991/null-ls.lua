local null_ls = require("null-ls")
local null_ls_helpers = require("null-ls.helpers")

local jenkins_lint = {
  method = null_ls.methods.DIAGNOSTICS,
  filetypes = { "Jenkinsfile" },
  generator = null_ls_helpers.generator_factory {
    command = "java",
    args = {'-jar', os.getenv('JENKINS_CLI'), 'declarative-linter'},
    to_stdin = true,
    check_exit_code = function(code)
      return code <= 1
    end,
    on_output = function(params, done)
      local diags = {}
      for _, line in ipairs(vim.split(params.output, "\n")) do
        local ok, _, msg, row, col = line:find('^WorkflowScript: %d+: (.+) @ line (%d+), column (%d+).')
        if ok then
          diags[#diags+1] = {
            row = row,
            col = col - 1,
            message = msg,
            severity = 1,
            source = "Jenkins",
          }
        end
      end

      return done(diags)
    end,
  }
}

null_ls.setup {
  sources = {
    -- null_ls.builtins.diagnostics.teal,
    null_ls.builtins.diagnostics.shellcheck,
    null_ls.builtins.diagnostics.pylint,
    null_ls.builtins.diagnostics.flake8,
    -- null_ls.builtins.diagnostics.luacheck,
    -- null_ls.builtins.code_actions.gitsigns,
    jenkins_lint,
  },
  diagnostics_format = "#{s}: #{m}",
  on_attach = function(_, bufnr)
    local keymap = function(key, result)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', key, '<cmd>lua '..result..'<CR>',
        {noremap = true, silent = true})
    end

    -- keymap('<C-]>'     , 'vim.lsp.buf.definition()')
    -- keymap('K'         , 'vim.lsp.buf.hover()')
    -- keymap('gK'        , 'vim.lsp.buf.signature_help()')
    -- keymap('<C-s>'     , 'vim.lsp.buf.signature_help()')
    -- keymap('gr'        , 'vim.lsp.buf.references()')
    -- keymap('<leader>rn', 'vim.lsp.buf.rename()')
    keymap('<leader>ca', 'vim.lsp.buf.code_action()')
    keymap('<leader>e' , 'vim.lsp.diagnostic.show_line_diagnostics()')
    keymap(']d'        , 'vim.lsp.diagnostic.goto_next()')
    keymap('[d'        , 'vim.lsp.diagnostic.goto_prev()')
    keymap('go'        , 'vim.lsp.diagnostic.set_loclist()')

    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  end
}
