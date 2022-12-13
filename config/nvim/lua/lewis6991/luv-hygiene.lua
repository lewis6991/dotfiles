local handles = setmetatable({}, { __mode = 'k' })

-- known handles which are intended to stay open
local excludes = {
  "runtime/lua/vim/lsp/rpc%.lua:.*: in function 'start'",
  "gitsigns/current_line_blame%.lua",
  "gitsigns/manager%.lua:.*: in function 'update_cwd_head'",
  "gitsigns/manager%.lua:.*: in function 'watch_gitdir'",
  "gitsigns/debounce%.lua:.*: in function 'debounce_trailing'"
}

local function is_excluded(lines)
  for _, l in ipairs(lines) do
    for _, e in ipairs(excludes) do
      if l:match(e) then
        return true
      end
    end
  end
  return false
end

function _G.print_handles()
  local none = true
  for handle, e in pairs(handles) do
    local fn, msg = unpack(e)
    if handle and (not handle.is_closing or not handle:is_closing()) then
      local lines = vim.split(msg, '\n')
      if not is_excluded(lines) then
        print(fn, ':')
        for i, l in ipairs(lines) do
          print('   ', l)
          if i == 5 then
            break
          end
        end
        print(' ')
        none = false
      end
    end
  end
  if none then
    print('No active handles')
  end
end

for _, fn in ipairs {
  'new_async',
  'new_check',
  'new_fs_event',
  'new_fs_poll',
  'new_idle',
  'new_pipe',
  'new_poll',
  'new_prepare',
  'new_signal',
  'new_socket_poll',
  'new_tcp',
  'new_thread',
  'new_timer',
  'new_tty',
  'new_udp',
  'new_work',
  'spawn',
} do
  local orig = vim.loop[fn]
  vim.loop[fn] = function(...)
    local r = {orig(...)}
    if type(r[1]) == 'userdata' then
      handles[r[1]] = {fn, debug.traceback('', 2)}
    end
    return unpack(r)
  end
end
