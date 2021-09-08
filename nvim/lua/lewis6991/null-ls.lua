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

local keymap = function(bufnr, key, result)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', key, result, {noremap = true})
end

null_ls.setup {
  on_attach = function(_, bufnr)
    keymap(bufnr, ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>')
    keymap(bufnr, '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>')
    keymap(bufnr, 'go', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>')
  end,
  diagnostics_format = "#{s}: #{m}",
  sources = {
    null_ls.builtins.diagnostics.teal,
    null_ls.builtins.diagnostics.shellcheck,
    null_ls.builtins.diagnostics.pylint,
    null_ls.builtins.diagnostics.flake8,
    -- null_ls.builtins.diagnostics.luacheck,
    -- null_ls.builtins.code_actions.gitsigns,
    jenkins_lint,
  }
}
