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

local flake8_ignores = {
  'E501', -- line too long
  'E221', -- multiple space before operators
  'E201', -- whitespace before/after '['/']'
  'E202', -- whitespace before ']'
  'E272', -- multiple spaces before keyword
  'E241', -- multiple spaces after ':'
  'E231', -- missing whitespace after ':'
  'E203', -- whitespace before ':'
  'E741', -- ambiguous variable name
  'E226', -- missing whitespace around arithmetic operator
}

local shellcheck_ignores = {
  '1003', -- Want to escape a single quote? echo 'This is how it'\''s done'.
}

null_ls.setup {
  sources = {
    -- null_ls.builtins.diagnostics.teal,
    null_ls.builtins.diagnostics.shellcheck.with {
      extra_args = { '--exclude', table.concat(shellcheck_ignores, ',')}
    },
    -- null_ls.builtins.diagnostics.pylint,
    null_ls.builtins.diagnostics.flake8.with{
      extra_args = { '--ignore', table.concat(flake8_ignores, ',')}
    },
    null_ls.builtins.diagnostics.luacheck,
    null_ls.builtins.code_actions.gitsigns,
    jenkins_lint,
  },
  diagnostics_format = "#{s}: #{m} (#{c})",
  on_attach = function(_, bufnr)
    local keymap = function(key, result)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', key, '<cmd>lua '..result..'<CR>',
        {noremap = true, silent = true})
    end

    keymap('<leader>ca', 'vim.lsp.buf.code_action()')
    keymap('<leader>e' , 'vim.lsp.diagnostic.show_line_diagnostics()')
    keymap(']d'        , 'vim.lsp.diagnostic.goto_next()')
    keymap('[d'        , 'vim.lsp.diagnostic.goto_prev()')
    keymap('go'        , 'vim.lsp.diagnostic.set_loclist()')

    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  end
}
