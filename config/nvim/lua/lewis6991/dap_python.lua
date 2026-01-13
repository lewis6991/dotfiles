local api = vim.api
local M = {}
local uv = vim.uv or vim.loop

--- @param node TSNode
local function get_node_text(node)
  return vim.treesitter.get_node_text(node, 0)
end

--- @return fun():string?
local function roots()
  return coroutine.wrap(function()
    local cwd = vim.fn.getcwd()
    coroutine.yield(cwd)

    local wincwd = vim.fn.getcwd(0)
    if wincwd ~= cwd then
      coroutine.yield(wincwd)
    end

    for _, client in ipairs(vim.lsp.get_clients()) do
      if client.config.root_dir then
        coroutine.yield(client.config.root_dir)
      end
    end
  end)
end

local function default_runner()
  for root in roots() do
    if uv.fs_stat(root .. '/pyproject.toml') then
      local f = io.open(root .. '/pyproject.toml')
      if f then
        for line in f:lines() do
          if line:find('%[tool.pytest') then
            f:close()
            return 'pytest'
          end
        end
        f:close()
      end
    end
  end

  return 'unittest'
end

local default_test_opts = {
  console = 'integratedTerminal',
}

local function load_dap()
  local ok, dap = pcall(require, 'dap')
  assert(ok, 'nvim-dap is required to use dap-python')
  return dap
end

local function get_module_path()
  return vim.fn.expand('%:.:r:gs?/?.?')
end

---@return string[]
local function flatten(...)
  return vim.iter({ ... }):flatten(2):totable()
end

M.test_runners = {}

---@private
---@param classnames string[]|string
---@param methodname string?
function M.test_runners.unittest(classnames, methodname)
  local test_path = table.concat(flatten(get_module_path(), classnames, methodname), '.')
  local args = { '-v', test_path }
  return 'unittest', args
end

---@private
---@param classnames string[]|string
---@param methodname string?
function M.test_runners.pytest(classnames, methodname)
  local path = vim.fn.expand('%:p')
  local test_path = table.concat(flatten({ path, classnames, methodname }), '::')
  -- -s "allow output to stdout of test"
  local args = { '-s', test_path }
  return 'pytest', args
end

--- Reverse list inline
---@param list any[]
local function reverse(list)
  local len = #list
  for i = 1, math.floor(len * 0.5) do
    local opposite = len - i + 1
    list[i], list[opposite] = list[opposite], list[i]
  end
end

---@private
---@param source integer
---@param subject "function"|"class"
---@param end_row integer? defaults to cursor
---@return TSNode[]
local function get_nodes(source, subject, end_row)
  end_row = end_row or api.nvim_win_get_cursor(0)[1]
  local query_text = [[
    (function_definition
      name: (identifier) @function
    )

    (class_definition
      name: (identifier) @class
    )
  ]]
  local lang = 'python'
  local query = vim.treesitter.query.parse(lang, query_text)
  local parser = assert(vim.treesitter.get_parser(source, lang))
  local trees = assert(parser:parse())
  local root = trees[1]:root()
  local nodes = {} --- @type TSNode[]
  for id, node in query:iter_captures(root, source, 0, end_row) do
    if query.captures[id] == subject then
      table.insert(nodes, node)
    end
  end
  if not next(nodes) then
    return nodes
  end
  if subject == 'function' then
    local result = nodes[#nodes]
    local parent = result
    while parent ~= nil do
      if parent:type() == 'function_definition' then
        local ident --- @type TSNode?
        if parent:child(1):type() == 'identifier' then
          ident = parent:child(1)
        elseif parent:child(2) and parent:child(2):type() == 'identifier' then
          ident = parent:child(2)
        end
        result = ident
      end
      parent = parent:parent()
    end
    return { result }
  elseif subject == 'class' then
    local last = nodes[#nodes]
    local parent = last
    local results = {}
    while parent ~= nil do
      if parent:type() == 'class_definition' then
        local ident = parent:child(1)
        assert(ident:type() == 'identifier')
        table.insert(results, ident)
      end
      parent = parent:parent()
    end
    reverse(results)
    return results
  end
  error("Expected subject 'function' or 'class', not: " .. subject)
end

---@param classnames string[]
---@param methodname string?
---@param opts dap-python.debug_opts
local function trigger_test(classnames, methodname, opts)
  local test_runner = opts.test_runner or default_runner()
  local runner = M.test_runners[test_runner]
  if not runner then
    vim.notify('Test runner `' .. test_runner .. '` not supported', vim.log.levels.WARN)
    return
  end
  assert(type(runner) == 'function', 'Test runner must be a function')
  -- for BWC with custom runners which expect a string instead of a list of strings
  local classes = #classnames == 1 and classnames[1] or classnames
  local module, args = runner(classes, methodname)
  local config = {
    name = table.concat(flatten(classnames, methodname), '.'),
    type = 'python',
    request = 'launch',
    module = module,
    args = args,
    console = opts.console,
  }
  local opts_config = opts.config or {}
  if type(opts_config) == 'function' then
    config = opts_config(config)
  elseif type(opts_config) == 'table' then
    config = vim.tbl_extend('force', config, opts_config)
  else
    error('opts.config must be a table, got: ' .. type(opts_config))
  end
  ---@cast config dap.Configuration
  load_dap().run(config)
end

--- Run test class above cursor
---@param opts? dap-python.debug_opts See |dap-python.debug_opts|
function M.test_class(opts)
  opts = vim.tbl_extend('keep', opts or {}, default_test_opts)
  local candidates = get_nodes(0, 'class')
  if not candidates then
    print('No test class found near cursor')
    return
  end
  local names = vim.tbl_map(get_node_text, candidates)
  trigger_test(names, nil, opts)
end

---@param node TSNode
---@result TSNode[]
local function get_parent_classes(node)
  local parent = node:parent()
  local result = {}
  while parent ~= nil do
    if parent:type() == 'class_definition' then
      local ident = parent:child(1)
      assert(ident and ident:type() == 'identifier')
      table.insert(result, ident)
    end
    parent = parent:parent()
  end
  reverse(result)
  return result
end

--- Run the test method above cursor
---@param opts? dap-python.debug_opts See |dap-python.debug_opts|
function M.test_method(opts)
  opts = vim.tbl_extend('keep', opts or {}, default_test_opts)
  local func_nodes = get_nodes(0, 'function')

  if not func_nodes or not func_nodes[1] then
    print('No test method found near cursor')
    return
  end

  local func_node = func_nodes[1]

  local parent_classes = get_parent_classes(func_node)

  local classnames = vim.tbl_map(get_node_text, parent_classes)
  trigger_test(classnames, get_node_text(func_node), opts)
end

---@class dap-python.PathMapping
---@field localRoot string
---@field remoteRoot string

---@class dap-python.Config
---@field gevent boolean|nil Enable debugging of gevent monkey-patched code. Default is `false`
---@field jinja boolean|nil Enable jinja2 template debugging. Default is `false`
---@field justMyCode boolean|nil Debug only user-written code. Default is `true`
---@field pathMappings dap-python.PathMapping[]|nil Map of local and remote paths.
---@field pyramid boolean|nil Enable debugging of pyramid applications
---@field redirectOutput boolean|nil Redirect output to debug console. Default is `false`
---@field showReturnValue boolean|nil Shows return value of function when stepping
---@field sudo boolean|nil Run program under elevated permissions. Default is `false`

---@class dap-python.debug_opts
---@field console? dap-python.console
---@field test_runner? "unittest"|"pytest"|string name of the test runner
---@field config? dap-python.Config|fun(config:dap-python.Config):dap-python.Config Overrides for the configuration

---@class dap-python.setup.opts
---@field include_configs? boolean Add default configurations
---@field console? dap-python.console
---
--- Path to python interpreter. Uses interpreter from `VIRTUAL_ENV` environment
--- variable or `python_path` by default
---@field pythonPath? string

--- A function receiving classname and methodname; must return module to run and its arguments
---@alias dap-python.TestRunner fun(classname: string|string[], methodname: string?):string, string[]

---@alias dap-python.console 'internalConsole'|'integratedTerminal'|'externalTerminal'|nil

return M
