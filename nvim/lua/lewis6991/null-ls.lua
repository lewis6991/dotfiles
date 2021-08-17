local null_ls = require("null-ls")
local null_ls_helpers = require("null-ls.helpers")

null_ls.setup {
  sources = {
    null_ls.builtins.diagnostics.teal,
    null_ls.builtins.diagnostics.shellcheck,
    null_ls.builtins.code_actions.gitsigns,
  },
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

local pylint_lint = {
  method = null_ls.methods.DIAGNOSTICS,
  filetypes = { "python" },
  generator = null_ls_helpers.generator_factory {
    command = "pylint",
    args = {"--output-format=json", '--from-stdin', '$FILENAME'},
    to_stdin = true,
    format = 'json',
    check_exit_code = function()
      return true
    end,
    on_output = function(params)
      local diagnostics = {}
      for _, d in ipairs(params.output) do
        diagnostics[#diagnostics+1] = {
          source = 'pylint',
          row = d.line,
          col = d.column - 1,
          message = string.format('[%s] %s', d.symbol, d.message),
          code = d['message-id'],
          severity = d.type == "error" and 1
                  or d.type == "fatal" and 1
                  or d.type == "warning" and 2
                  or d.type == "informational" and 3
                  or d.type == "refactor" and 3
                  or d.type == "convention" and 4,
        }
        -- "module": "fts.colors",
        -- "obj": "",
        -- "path": "fts/colors.py",
      end
      return diagnostics
    end,
  },
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
    -- null_ls.builtins.code_actions.gitsigns,
    jenkins_lint,
    pylint_lint,
  }
}
