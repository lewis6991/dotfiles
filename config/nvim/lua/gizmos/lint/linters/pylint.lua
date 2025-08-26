--- @class gizmos.lint.pylint.result
--- @field messages gizmos.lint.pylint.result.message[]
--- @field statistics table

--- @class gizmos.lint.pylint.result.message
--- @field path? string
--- @field absolutePath? string
--- @field column integer
--- @field endColumn integer
--- @field line integer
--- @field endLine integer
--- @field type string
--- @field message string
--- @field symbol string
--- @field ['message-id'] string

local pylint_severities = {
  error = vim.diagnostic.severity.ERROR,
  fatal = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  refactor = vim.diagnostic.severity.INFO,
  info = vim.diagnostic.severity.INFO,
  convention = vim.diagnostic.severity.HINT,
}

--- @type gizmos.lint.Linter
return {
  name = 'pylint',
  stdin = true,
  cmd = { 'pylint', '--output-format', 'json2', '--from-stdin', '<FILE>' },
  env = function()
    return {
      PYLINTRC = vim.env.PYLINTRC or vim.fn.expand('$XDG_CONFIG_HOME/pylint/pylintrc.toml'),
    }
  end,
  ignore_exitcode = true,
  parser = function(bufnr, output)
    local diagnostics = {} --- @type vim.Diagnostic[]

    --- @type gizmos.lint.pylint.result
    local res = vim.json.decode(output)

    local msgs = res.messages

    for _, item in ipairs(msgs) do
      local column = item.column > 0 and item.column or 0
      local end_column = item.endColumn ~= vim.NIL and item.endColumn or column
      local end_line = item.endLine ~= vim.NIL and item.endLine or item.line
      diagnostics[#diagnostics + 1] = {
        lnum = item.line - 1,
        bufnr = bufnr,
        col = column,
        end_lnum = end_line - 1,
        end_col = end_column,
        severity = pylint_severities[item.type],
        message = ('%s(%s)'):format(item.message, item.symbol),
        code = item['message-id'],
        user_data = {
          lsp = {
            code = item['message-id'],
          },
        },
      }
    end
    return diagnostics
  end,
}
