
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
  cmd = { 'pylint', '-f', 'json', '--from-stdin', '<FILE>' },
  ignore_exitcode = true,
  parser = function(_bufnr, output)
    local diagnostics = {} --- @type vim.Diagnostic[]

    --- @class pylint.result
    --- @field path? string
    --- @field column integer
    --- @field endColumn integer
    --- @field line integer
    --- @field type string
    --- @field message string
    --- @field symbol string
    --- @field ['message-id'] string

    --- @type pylint.result[]
    local res = vim.json.decode(output)

    for _, item in ipairs(res) do
      local column = item.column > 0 and item.column or 0
      local end_column = item.endColumn ~= vim.NIL and item.endColumn or column
      diagnostics[#diagnostics + 1] = {
        lnum = item.line - 1,
        col = column,
        end_lnum = item.line - 1,
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
