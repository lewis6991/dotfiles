local cmd = vim.cmd

local actions = {}

local function set(fn)
  local id = string.format('%p', fn)
  actions[id] = fn
  return string.format('lua autocmd.exec("%s")', id)
end

local function autocmd(_, event, spec)
  local is_table = type(spec) == 'table'
  local pattern = is_table and spec[1] or '*'
  local action = is_table and spec[2] or spec
  if type(action) == 'function' then
    action = set(action)
  end
  if is_table then
    if spec.once   then pattern = pattern..' ++once'   end
    if spec.nested then pattern = pattern..' ++nested' end
  end
  local e = type(event) == 'table' and table.concat(event, ',') or event
  cmd('autocmd ' .. e .. ' ' .. pattern .. ' ' .. action)
end

local S = {}

local X = setmetatable({}, {
  __index = S,
  __newindex = autocmd,
  __call = autocmd,
})

function S.exec(id)
  actions[id]()
end

function S.group(grp, cmds)
  cmd('augroup ' .. grp)
  cmd('autocmd!')
  if type(cmds) == 'function' then
    cmds(X)
  else
    for _, au in ipairs(cmds) do
      autocmd(S, au[1], { au[2], au[3] })
    end
  end
  cmd('augroup END')
end

_G.autocmd = X

return X
