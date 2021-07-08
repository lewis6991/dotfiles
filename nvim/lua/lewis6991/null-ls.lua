local null_ls = require("null-ls")
local null_ls_helpers = require("null-ls.helpers")

null_ls.setup {sources = {
  null_ls.builtins.diagnostics.teal,
  null_ls.builtins.diagnostics.shellcheck,
  null_ls.builtins.code_actions.gitsigns,
}}

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

null_ls.register(jenkins_lint)

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

null_ls.register(pylint_lint)
