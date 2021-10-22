local void = require('plenary.async.async').void
local wrap = require('plenary.async.async').wrap
local scheduler = require('plenary.async.util').scheduler
local kinds = require('cmp.types').lsp.CompletionItemKind

local MAX_RESULTS = 100

local job = wrap(function(obj, callback)
  local stdout_data = {}
  local stdout = vim.loop.new_pipe(false)

  local handle = vim.loop.spawn(obj[1], {
    args  = vim.list_slice(obj, 2),
    stdio = { nil, stdout },
    cwd   = obj.cwd
  },
    function()
      stdout:close()
      local stdout_result = #stdout_data > 0 and table.concat(stdout_data) or nil
      callback(stdout_result)
    end
  )

  if handle then
    stdout:read_start(function(_, data)
      stdout_data[#stdout_data+1] = data
    end)
  else
    stdout:close()
  end
end, 2)

local source = {}

source.new = function()
  return setmetatable({ cache = {} }, { __index = source })
end

local function process_results(result, detail)
  local ok, parsed = pcall(vim.json.decode, result)
  if not ok then
    scheduler()
    vim.notify "Failed to parse gh result"
    return {}
  end

  local items = {}
  for _, gh_item in ipairs(parsed) do
    items[#items+1] = {
      label = string.format("#%s", gh_item.number),
      detail = detail,
      kind = kinds.Reference,
      documentation = {
        kind = "markdown",
        value = string.format("# %s\n\n%s", gh_item.title, gh_item.body),
      }
    }
  end

  return items
end

source.complete = void(function(self, _, callback)
  local bufnr = vim.api.nvim_get_current_buf()
  if self.cache[bufnr] then
    callback { items = self.cache[bufnr] }
    return
  end

  local cwd = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':p:h')

  local issue_stdout = job {
    'gh', 'issue', 'list', '--limit', MAX_RESULTS, '--json', 'title,number,body',
    cwd = cwd
  }

  local pr_stdout = job {
    'gh', 'pr', 'list', '--limit', MAX_RESULTS, '--json', 'title,number,body',
    cwd = cwd
  }

  local items = vim.list_extend(
    process_results(issue_stdout, 'Issue'),
    process_results(pr_stdout   , 'PR')
  )

  self.cache[bufnr] = items
  callback { items = items }
end)

function source.get_trigger_characters()
  return { "#" }
end

require('cmp').register_source("gh", source.new())
