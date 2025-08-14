local api = vim.api

--- @class gizmos.lint.Linter
--- @field name string
--- @field cmd (string|fun(bufnr: integer):string)[]
---
--- Send content via stdin. Defaults to false
--- @field stdin? boolean
---
--- Result stream. Defaults to stdout
--- @field stream? 'stdout'|'stderr'
---
--- If exit code != 1 should be ignored or result in a warning. Defaults to false
--- @field ignore_exitcode? boolean
---
--- Defaults to buffer directory if it exists
--- @field cwd? string
---
--- @field predicate? fun(bufnr: integer): boolean?
---
--- @field parser fun(bufnr: integer, output: string): vim.Diagnostic[]
---
--- @field ns? integer
---
--- bufnr -> vim.SystemObj
--- @field package _running? table<integer, vim.SystemObj>
--- @field package _disabled? boolean

local M = {}

--- A table listing which linters to run via `lint()`.
--- The key is the filetype. The values are a list of linter objects
---
--- Example:
---
--- ```lua
--- require('lint').linters = {
---   python = { pylint, flake8 },
--- }
--- ```
---
--- @type table<string, (string|gizmos.lint.Linter)[]>
M.linters = {}

local unknown_id = 1

--- @param linter string|gizmos.lint.Linter
--- @param ft string
--- @return gizmos.lint.Linter? linter
local function resolve_linter(linter, ft)
  if type(linter) == 'string' then
    --- @type boolean, any
    local ok, r = pcall(require, 'gizmos.lint.linters.' .. linter)
    if ok then
      --- @cast r gizmos.lint.Linter
      linter = r
    else
      vim.notify_once(('Linter "%s" not found. Error: %s'):format(linter, r), vim.log.levels.WARN)
      return
    end
  end

  if not linter.name then
    linter.name = ('%s%d'):format(ft, unknown_id)
    unknown_id = unknown_id + 1
  end
  linter.ns = linter.ns or api.nvim_create_namespace('lint.' .. linter.name)
  linter.stream = linter.stream or 'stdout'
  assert(
    linter.stream == 'stdout' or linter.stream == 'stderr',
    'Invalid stream: ' .. linter.stream
  )

  linter._running = linter._running or {}

  return linter
end

--- @param bufnr integer
--- @param cmd string[]
--- @param linter gizmos.lint.Linter
--- @param obj vim.SystemCompleted
local function on_result(bufnr, cmd, linter, obj)
  local code = obj.code
  if code ~= 0 and not linter.ignore_exitcode then
    vim.notify(
      ('Exit code %d from linter command:\n  %s'):format(code, table.concat(cmd, ' ')),
      vim.log.levels.WARN
    )
    return
  end

  -- By the time the linter is finished the user might have deleted the buffer
  if not api.nvim_buf_is_valid(bufnr) then
    return
  end

  local output = obj[linter.stream] --[[@as string]]
  if output == '' then
    vim.diagnostic.set(linter.ns, bufnr, {})
    return
  end

  local ok, diags = pcall(linter.parser, bufnr, output)
  if not ok then
    diags = {
      {
        bufnr = bufnr,
        lnum = 0,
        col = 0,
        message = ('Parser failed. Error messages:\n%s\n\nOutput from linter:\n%s\n'):format(
          diags,
          output
        ),
        severity = vim.diagnostic.severity.ERROR,
        source = linter.name,
      },
    }
  end
  for _, diag in ipairs(diags) do
    diag.source = diag.source or linter.name
  end
  vim.diagnostic.set(linter.ns, bufnr, diags)
end

--- @param bufnr integer
--- @param cmd (string|fun(bufnr: integer):string)[]
--- @return string[]
local function resolve_cmd(bufnr, cmd)
  local bufname = api.nvim_buf_get_name(bufnr)
  return vim.tbl_map(
    --- @param x string|fun(bufnr: integer):string
    --- @return string
    function(x)
      if type(x) == 'function' then
        return x(bufnr)
      end
      return (x:gsub('<FILE>', bufname))
    end,
    cmd
  )
end

--- @param bufnr integer
--- @return string?
local function resolve_cwd(bufnr)
  local bufcwd = vim.fs.dirname(api.nvim_buf_get_name(bufnr))
  if vim.uv.fs_stat(bufcwd) then
    return bufcwd
  end
end

--- Runs the given linter.
--- This is usually not used directly but called via `try_lint`
---
---@param bufnr integer
---@param linter gizmos.lint.Linter
---@return vim.SystemObj?
local function run(bufnr, linter)
  assert(linter, 'lint must be called with a linter')
  bufnr = bufnr or api.nvim_get_current_buf()

  local cmd = resolve_cmd(bufnr, linter.cmd)

  if vim.fn.executable(cmd[1]) == 0 then
    linter._disabled = true
    vim.notify(
      ('Linter "%s" is not executable. Command: %s'):format(linter.name, cmd[1]),
      vim.log.levels.WARN
    )
    return
  end

  local ok, handle = pcall(vim.system, cmd, {
    stdin = linter.stdin and api.nvim_buf_get_lines(bufnr, 0, -1, true) or nil,
    cwd = resolve_cwd(bufnr),
    -- Linter may launch child processes so set this as a group leader and
    -- manually track and kill processes as we need to.
    -- Don't detach on windows since that may cause shells to
    -- pop up shortly.
    detached = true,
  }, function(obj)
    vim.schedule(function()
      on_result(bufnr, cmd, linter, obj)
    end)
  end)

  if not ok then
    error(('Error running %s: %s'):format(vim.inspect(cmd), handle), vim.log.levels.ERROR)
  end

  return handle
end

--- @generic F
--- @param delay integer
--- @param fn F
--- @return F
local function debounce(delay, fn)
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

--- @param bufnr? integer
--- @param opts? {ignore_errors?: boolean}
M.lint = debounce(1000, function(bufnr, opts)
  opts = opts or {}
  bufnr = bufnr or api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype
  local linters = M.linters[ft] or {}

  for _, linter0 in pairs(linters) do
    local linter = resolve_linter(linter0, ft)
    if linter and not linter._disabled and (not linter.predicate or linter.predicate(bufnr)) then
      -- Kill any previous process for this linter
      local proc = linter._running[bufnr]
      if proc then
        -- Use sigint so the process can safely close any child processes.
        -- This is mostly useful for when `cmd` is a script with a shebang.
        proc:kill('sigint')
        linter._running[bufnr] = nil
      end

      local ok, lintproc_or_error = pcall(run, bufnr, linter)
      if ok then
        --- @cast lintproc_or_error -?
        linter._running[bufnr] = lintproc_or_error
      elseif not opts.ignore_errors then
        vim.notify_once(lintproc_or_error --[[@as string]], vim.log.levels.WARN)
      end
    end
  end
end)

--- kill any running processes when leaving
api.nvim_create_autocmd('VimLeavePre', {
  group = api.nvim_create_augroup('lint', { clear = true }),
  callback = function()
    for ft, linters in pairs(M.linters) do
      for _, linter0 in pairs(linters) do
        local linter = resolve_linter(linter0, ft)
        if linter then
          for _, proc in pairs(linter._running or {}) do
            proc:kill('sigint')
          end
        end
      end
    end
  end,
})

return M
