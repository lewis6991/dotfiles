--- @param expected string
--- @param original string
--- @return integer col
--- @return integer end_col
local function narrow_diff(original, expected)
  local col = 0
  local end_col = math.huge

  for i = 1, math.min(#original, #expected) do
    if original:sub(i, i) ~= expected:sub(i, i) then
      col = i - 1
      break
    end
  end

  local original_last_line = expected:match('[^\n]*$')
  local expected_last_line = original:match('[^\n]*$')

  if expected_last_line and original_last_line then
    for i = 1, math.min(#expected_last_line, #original_last_line) do
      if original:sub(-i, -i) ~= expected:sub(-i, -i) then
        end_col = #original_last_line - (i - 1)
        break
      end
    end
  end

  return col, end_col
end

--- @type gizmos.lint.Linter
return {
  name = 'stylua_lint',
  cmd = {
    'stylua',
    '--check',
    '--search-parent-directories',
    '--output-format=json',
    '--stdin-filepath=<FILE>',
    '-',
  },
  stdin = true,
  ignore_exitcode = true,
  parser = function(_bufnr, output)
    local diags = {} --- @type vim.Diagnostic[]
    --- @class stylua.result.mismatches
    --- @field expected string
    --- @field expected_start_line integer
    --- @field expected_end_line integer
    --- @field original string
    --- @field original_start_line integer
    --- @field original_end_line integer

    --- @class stylua.result
    --- @field file string
    --- @field mismatches stylua.result.mismatches[]
    local res = vim.json.decode(output)
    for _, mismatch in ipairs(res.mismatches) do
      local original = mismatch.original
      local expected = mismatch.expected

      local msg --- @type string
      if expected == '' and original:match('^\n+$') then
        msg = 'remove newline(s)'
      else
        local original_stripped = original:gsub('%s+$', '')
        local expected_stripped = expected:gsub('%s+$', '')
        if expected_stripped == original_stripped then
          msg = 'remove trailing whitespace'
        elseif expected_stripped:gsub(',$', '') == original_stripped then
          msg = 'missing comma'
        else
          msg = '-' .. original:gsub('\n', '\n-') .. '\n+' .. expected:gsub('\n', '\n+')
        end
      end

      local col, _end_col = narrow_diff(original, expected)

      diags[#diags + 1] = {
        lnum = mismatch.original_start_line,
        end_lnum = mismatch.original_end_line,
        col = col,
        end_col = col,
        -- end_col = end_col,
        message = msg,
        severity = vim.diagnostic.severity.HINT,
      }
    end
    return diags
  end,
}
