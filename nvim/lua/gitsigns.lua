local Job = require('plenary.job')
local CM = require('plenary.context_manager')
local FN = require('plenary.functional')

local AS = require('gitsigns/async')

local async = AS.async
local await = AS.await
local await_main = AS.await_main

local map = FN.map
local with = CM.with
local open = CM.open

local count = 0

local sign_map = {
  add          = "GitSignsAdd",
  delete       = "GitSignsDelete",
  change       = "GitSignsChange",
  topdelete    = "GitSignsTopDelete",
  changedelete = "GitSignsChangeDelete",
}

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
    start   = added.start,
    head    = line,
    lines   = {},
    removed = removed,
    added   = added
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

local write_to_file = function(file, content)
    with(open(file, 'w'), function(writer)
      for _, l in pairs(content) do
        writer:write(l..'\n')
      end
    end)
end

local update_status = function(status, diff)
    if diff.type == 'add' then
      status.added = status.added + diff.added.count
    elseif diff.type == 'delete' then
      status.removed = status.removed + diff.removed.count
    elseif diff.type == 'change' then
      local add, remove = diff.added.count, diff.removed.count
      local min = math.min(add, remove)
      status.changed = status.changed + min
      status.added   = status.added   + add - min
      status.removed = status.removed + remove - min
    end
end

local process_diffs = function(diffs)
  local status = { added = 0, changed = 0, removed = 0 }

  local signs = {}
  local add_sign2 = function(type, lnum)
    table.insert(signs, {type = type, lnum = lnum})
  end

  for _, diff in pairs(diffs) do
    update_status(status, diff)

    for i = diff.start, diff.dend do
      local topdelete = diff.type == 'delete' and i == 0
      local changedelete = diff.type == 'change' and diff.removed.count > diff.added.count and i == diff.dend
      add_sign2(
        topdelete and 'topdelete' or changedelete and 'changedelete' or diff.type,
        topdelete and 1 or i
      )
    end
    if diff.type == "change" then
      local add, remove = diff.added.count, diff.removed.count
      if add > remove then
        for i = 1, add - remove do
          add_sign2('add', diff.dend + i)
        end
      end
    end
  end

  return status, signs
end

-- to be used with await
local get_staged = function(path, callback)
  local staged = os.tmpname()
  local content = {}
  local valid = true
  Job:new {
    command = 'git',
    args = {'--no-pager', 'show', ':./'..path},
    on_stdout = function(_, line, _)
      table.insert(content, line)
    end,
    on_stderr = function()
      valid = false
    end,
    on_exit = function()
      if valid then
        write_to_file(staged, content)
      end
      callback(valid, staged)
    end
  }:start()
end

-- to be used with await
local run_diff = function(staged, current, callback)
  local results = {}
  Job:new {
    command = 'git',
    args = {'--no-pager', 'diff', '--patch-with-raw', '--unified=0', '--no-color', staged, current},
    on_stdout = function(_, line, _)
      if vim.startswith(line, '@@') then
        table.insert(results, parse_diff_line(line))
      else
        if #results > 0 then
          table.insert(results[#results].lines, line)
        end
      end
    end,
    on_exit = function()
      callback(results)
    end
  }:start()
end

local mk_status_txt = function(status)
  local added, changed, removed = status.added, status.changed, status.removed
  local status_txt = {}
  if added   > 0 then table.insert(status_txt, '+'..added  ) end
  if changed > 0 then table.insert(status_txt, '~'..changed) end
  if removed > 0 then table.insert(status_txt, '-'..removed) end
  return table.concat(status_txt, ' ')
end

local cache = {}

local find_diff = function(line, diffs)
  for _, diff in pairs(diffs) do
    if line == 1 and diff.start == 0 and diff.dend == 0 then
      return diff
    end

    local dend =
      diff.type == 'change' and diff.added.count > diff.removed.count and
        (diff.dend + diff.added.count - diff.removed.count) or
        diff.dend

    if diff.start <= line and dend >= line then
      return diff
    end
  end
end

local get_hunk = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  return find_diff(line, cache[bufnr])
end

local update = function()
  async(function()
    local file = vim.fn.expand('%t')
    local bufnr = vim.api.nvim_get_current_buf()
    local content = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local current = os.tmpname()

    write_to_file(current, content)

    local valid, staged = await(get_staged, file)
    if not valid then
      return
    end
    local diffs = await(run_diff, staged, current)

    cache[bufnr] = diffs

    local status, signs = process_diffs(diffs)
    await_main()

    vim.fn.sign_unplace('gitsigns_ns', {buffer = bufnr})
    for _, s in pairs(signs) do
      add_sign(bufnr, s.type, s.lnum)
    end

    vim.api.nvim_buf_set_var(bufnr, 'git_signs_status_dict', status)
    vim.api.nvim_buf_set_var(bufnr, 'git_signs_status', mk_status_txt(status))

    -- print("UPDATE: " .. count)
    count = count + 1
  end)()
end

local w = vim.loop.new_fs_event()

function watch_file(fname)
  w:start(fname, {}, vim.schedule_wrap(function(err, name, status)
    update()
  end))
end

local get_repo_root = function(callback)
  local root
  Job:new {
    command = 'git',
    args = {'rev-parse', '--show-toplevel'},
    on_stdout = function(_, line)
      root = line
    end,
    on_exit = function()
      callback(root)
    end
  }:start()
end

local init = function()
  async(function()
    local root = await(get_repo_root)
    local file = root..'/.git/index'
    watch_file(file)
  end)()
end
init()

local stage_lines = function(root, lines, callback)
  Job:new {
    command = 'git',
    args = {'apply', '--cached', '--unidiff-zero', '-'},
    cwd = root,
    writer = lines,
    on_stderr = function(_, line)
      print(line)
    end,
    on_exit = callback
  }:start()
end

local stage_hunk = function()
  local hunk = get_hunk()
  if not hunk then
    return
  end

  local type, added, removed = hunk.type, hunk.added, hunk.removed

  local ps, pc, ns, nc

  if type == 'add' then
    ps, pc, ns, nc = removed.start + 1, 0            , removed.start + 1, added.count
  elseif type == 'delete' then
    ps, pc, ns, nc = removed.start    , removed.count, removed.start    , 0
  elseif type == 'change' then
    ps, pc, ns, nc = removed.start    , removed.count, removed.start    , added.count
  end

  local head = string.format('@@ -%s,%s +%s,%s @@', ps, pc, ns, nc)

  local file = vim.fn.expand('%:p')

  async(function()
    local root = await(get_repo_root)

    local relpath = string.sub(file, #root + 2)

    local lines = {
      string.format('diff --git a/%s b/%s', relpath, relpath),
      'index 000000..000000 100644',
      '--- a/'..relpath,
      '+++ b/'..relpath,
      head,
      unpack(hunk.lines)
    }

    await_main()
    await(stage_lines, root, lines)

  end)()
end

local next_hunk = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local diffs = cache[bufnr]
  for _, diff in pairs(diffs) do
    if diff.start > line then
      vim.fn.cursor(diff.start, 0)
      return
    end
  end
  -- wrap around
  if vim.api.nvim_get_option('wrapscan') then
    vim.fn.cursor(math.max(diffs[1].start, 1), 0)
  end
end

local prev_hunk = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local diffs = cache[bufnr]
  for _, diff in pairs(diffs) do
    if diff.dend < line then
      vim.fn.cursor(diff.start, 0)
      return
    end
  end
  -- wrap around
  if vim.api.nvim_get_option('wrapscan') then
    vim.fn.cursor(math.max(diffs[#diffs].start, 1), 0)
  end
end

local keymap = function(mode, key, result)
  vim.api.nvim_buf_set_keymap(0, mode, key, result, {noremap = true, silent = true})
end

local default_config = {
  signs = {
    add          = {hl = 'GitGutterAdd'   , text = '│'},
    change       = {hl = 'GitGutterChange', text = '│'},
    delete       = {hl = 'GitGutterDelete', text = '_'},
    topdelete    = {hl = 'GitGutterDelete', text = 'X'},
    changedelete = {hl = 'GitGutterChange', text = '~'},
  },
  keymaps = {
    [']c']         = '<cmd>lua require"gitsigns".next_hunk()<CR>',
    ['[c']         = '<cmd>lua require"gitsigns".prev_hunk()<CR>',
    ['<leader>hs'] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
    ['<leader>gh'] = '<cmd>lua require"gitsigns".get_hunk()<CR>'
  }
}

return {
  update     = update,
  get_hunk   = get_hunk,
  stage_hunk = stage_hunk,
  next_hunk  = next_hunk,

  setup = function(config)
    config = vim.tbl_extend("keep", config or {}, default_config)

    for t, sign_name in pairs(sign_map) do
      vim.fn.sign_define(sign_map[t], {
        texthl = config.signs[t].hl,
        text   = config.signs[t].text
      })
    end

    vim.cmd('autocmd BufRead      * lua require"gitsigns".update()')
    vim.cmd('autocmd TextChanged  * lua require"gitsigns".update()')
    vim.cmd('autocmd TextChangedI * lua require"gitsigns".update()')

    for key, cmd in pairs(config.keymaps) do
      keymap('n', key, cmd)
    end
  end
}
