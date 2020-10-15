local Job = require('plenary.job')
local CM = require('plenary.context_manager')
local FN = require('plenary.functional')

local map = FN.map
local with = CM.with
local open = CM.open

local sign_map = {
  add          = "GitSignsAdd",
  delete       = "GitSignsDelete",
  change       = "GitSignsChange",
  topdelete    = "GitSignsTopDelete",
  changedelete = "GitSignsChangeDelete",
}

local capture = function(cmd)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  return s
end

local parse_diff_line = function(line)
  local diffkey = vim.trim(vim.split(line, '@@', true)[2])

  -- diffKey: "-xx,n +yy"
  -- pre: {xx, n}, now: {yy}
  local pre, now = unpack(map(function(s)
    return vim.split(string.sub(s, 2), ',')
  end, vim.split(diffkey, ' ')))

  local removed = { start = tonumber(pre[1]), count = tonumber(pre[2]) or 1 }
  local added   = { start = tonumber(now[1]), count = tonumber(now[2]) or 1 }

  local diff = {
    start = added.start,
    head = line,
    removed = removed,
    added = added
  }

  if added.count == 0 then
    -- delete
    diff.dend = added.start
    diff.type = "delete"
  elseif removed.count == 0 then
    -- add
    diff.dend = added.start + added.count - 1
    diff.type = "add"
  else
    -- change
    diff.dend = added.start + math.min(added.count, removed.count) - 1
    diff.type = "change"
  end
  return diff
end

local add_sign = function(bufnr, type, lnum)
  vim.fn.sign_place(0, 'gitsigns_ns', sign_map[type], bufnr, { lnum = lnum, priority = 100 })
end

-- local keymap = function(mode, key, result)
--   vim.api.nvim_buf_set_keymap(0, mode, key, result, {noremap = true, silent = true})
-- end

local gs = {}

gs.setup = function()
  local diff_results = {}

  local update_signs = function(bufnr)
    vim.fn.sign_unplace('gitsigns_ns', {buffer = bufnr})
    for _, diff in pairs(diff_results) do
      for i = diff.start, diff.dend do
        local topdelete = diff.type == 'delete' and i == 0
        local changedelete = diff.type == 'change' and diff.removed.count > diff.added.count and i == diff.dend
        add_sign(
          bufnr,
          topdelete and 'topdelete' or changedelete and 'changedelete' or diff.type,
          topdelete and 1 or i
        )
      end
      if diff.type == "change" then
        local add, remove = diff.added.count, diff.removed.count
        if add > remove then
          for i = 1, add - remove do
            add_sign(bufnr, 'add', diff.dend + i)
          end
        end
      end
    end
  end

  GitSignsUpdate = function()
    local file = vim.fn.expand('%t')
    local bufnr = vim.api.nvim_get_current_buf()
    local content = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    local current = "/tmp/lua_current"
    -- local current = os.tmpname()

    with(open(current, 'w'), function(writer)
      for _, l in pairs(content) do
        writer:write(l..'\n')
      end
    end)

    local staged = "/tmp/lua_staged"
    -- local staged = os.tmpname()

    diff_results = {}

    local staged_c = {}

    local not_git = false

    Job:new {
      command = 'git',
      args = {'--no-pager', 'show', ':./'..file},
      on_stdout = function(_, line, _)
        table.insert(staged_c, line)
      end,
      on_stderr = function(_, line, j)
        not_git = true
      end,
      on_exit = function()
        if not_git then
          return
        end

        with(open(staged, 'w'), function(writer)
          for _, l in pairs(staged_c) do
            writer:write(l..'\n')
          end
        end)

      end
    }:chain(Job:new {
      command = 'git',
      args = {'--no-pager', 'diff', '--patch-with-raw', '--unified=0', '--no-color', staged, current},
      on_stdout = function(_, line, _)
        if vim.startswith(line, '@@') then
          table.insert(diff_results, parse_diff_line(line))
        end
      end,
      on_exit = vim.schedule_wrap(function()
        update_signs(bufnr)
      end)
    })

  end

  vim.fn.sign_define('GitSignsAdd'         , { texthl = 'GitGutterAdd'   , text = "│" })
  vim.fn.sign_define('GitSignsChange'      , { texthl = 'GitGutterChange', text = "│" })
  vim.fn.sign_define('GitSignsDelete'      , { texthl = 'GitGutterDelete', text = "_" })
  vim.fn.sign_define('GitSignsTopDelete'   , { texthl = 'GitGutterDelete', text = "~" })
  vim.fn.sign_define('GitSignsChangeDelete', { texthl = 'GitGutterChange', text = "~" })

  vim.cmd('autocmd BufRead      * lua GitSignsUpdate()')
  vim.cmd('autocmd TextChanged  * lua GitSignsUpdate()')
  vim.cmd('autocmd TextChangedI * lua GitSignsUpdate()')
end

return gs
