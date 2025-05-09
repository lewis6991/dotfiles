local env = vim.env

local jenkins_lint --- @type table<string,any>
if env.JENKINS_CLI and env.JENKINS_URL and env.JENKINS_USER and env.JENKINS_AUTH_TOKEN then
  jenkins_lint = {
    cmd = {
      'java',
      '-jar',
      env.JENKINS_CLI,
      '-s',
      env.JENKINS_URL,
      '-noCertificateCheck',
      '-auth',
      env.JENKINS_USER .. ':' .. env.JENKINS_AUTH_TOKEN,
      'declarative-linter',
    },
    stdin = true,
    ignore_exitcode = true,
    parser = function(_bufnr, output)
      local diags = {} --- @type vim.Diagnostic[]
      for _, line in ipairs(vim.split(output, '\n')) do
        local ok, _, msg, lnum, col =
          line:find('^WorkflowScript: %d+: (.+) @ line (%d+), column (%d+).')
        if ok then
          diags[#diags + 1] = {
            lnum = tonumber(lnum - 1) --[[@as integer]],
            col = col - 1,
            message = msg,
            severity = 1,
          }
        end
      end

      return diags
    end,
  }
end

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

local stylua_lint = {
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

local tcl_lint = {
  cmd = { 'make', 'tcl_lint' },
  ignore_exitcode = true,
  parser = function(bufnr, output)
    local diags = {} --- @type vim.Diagnostic[]
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    for _, line in ipairs(vim.split(output, '\n')) do
      local ok, _, path, lnum, sev, msg = line:find('^([^:]+): Line%s+(%d+): (.) (.+)$')
      if ok and vim.endswith(bufname, path) then
        diags[#diags + 1] = {
          lnum = tonumber(lnum - 1) --[[@as integer]],
          col = 0,
          message = msg,
          severity = sev,
        }
      end
    end

    return diags
  end,
}

local pylint_severities = {
  error = vim.diagnostic.severity.ERROR,
  fatal = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  refactor = vim.diagnostic.severity.INFO,
  info = vim.diagnostic.severity.INFO,
  convention = vim.diagnostic.severity.HINT,
}

local pylint = {
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

local function do_setup()
  local lint = require('gizmos.lint')
  lint.linters = {
    jenkins_lint = jenkins_lint,
    tcl_lint = tcl_lint,
    stylua_lint = stylua_lint,
    pylint = pylint,
  }

  lint.linters_by_ft = {
    Jenkinsfile = jenkins_lint and { 'jenkins_lint' } or nil,
    tcl = { 'tcl_lint' },
    lua = { 'stylua_lint' },
  }
end

local function debounce(fn, delay)
  local timer = nil --- @type uv.uv_timer_t?
  return function(...)
    local args = { ... }
    if timer then
      timer:stop()
    end
    timer = vim.defer_fn(function()
      fn(unpack(args))
    end, delay)
  end
end

local did_setup = false

vim.api.nvim_create_autocmd({ 'InsertLeave', 'FileType', 'TextChanged', 'BufWrite' }, {
  callback = debounce(function()
    if not did_setup then
      do_setup()
      did_setup = true
    end
    require('gizmos.lint').lint()
  end, 1000),
})
