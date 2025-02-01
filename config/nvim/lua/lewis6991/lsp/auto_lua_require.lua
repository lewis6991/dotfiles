local api = vim.api

--- @param x string
--- @return string?
local function match_require(x)
  return x:match('require')
    and (
      x:match("require%s*%(%s*'([^.']+).*'%)") -- require('<module>')
      or x:match('require%s*%(%s*"([^."]+).*"%)') -- require("<module>")
      or x:match("require%s*'([^.']+).*'%)") -- require '<module>'
      or x:match('require%s*"([^."]+).*"%)') -- require "<module>"
      or x:match("pcall(require,%s*'([^.']+).*'%)") -- pcall(require, "<module>")
      or x:match('pcall(require,%s*"([^."]+).*"%)') -- pcall(require, "<module>")
    )
end

--- @param client vim.lsp.Client
--- @param bufnr integer
return function(client, bufnr)
  local local_ws = nil
  if client.workspace_folders then
    local path = client.workspace_folders[1].name
    local_ws = vim.fs.joinpath(path, 'lua')
    if vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc') then
      -- Updates to settings are ignored if a .luarc.json is present
      return
    end
  end

  client.settings = vim.tbl_deep_extend('keep', client.settings, {
    Lua = { workspace = { library = {} } },
  })

  --- @param first? integer
  --- @param last? integer
  local function on_lines(_, _, _, first, _, last)
    local did_change = false

    local lines = api.nvim_buf_get_lines(bufnr, first or 0, last or -1, false)
    for _, line in ipairs(lines) do
      local m = match_require(line)
      if m then
        for _, mod in ipairs(vim.loader.find(m, { patterns = { '', '.lua' } })) do
          local lib = vim.fs.dirname(mod.modpath)
          local libs = client.settings.Lua.workspace.library
          if not lib == local_ws and not vim.tbl_contains(libs, lib) then
            libs[#libs + 1] = lib
            did_change = true
          end
        end
      end
    end

    if did_change then
      client:notify('workspace/didChangeConfiguration', { settings = client.settings })
    end
  end

  api.nvim_buf_attach(bufnr, false, {
    on_lines = on_lines,
    on_reload = on_lines,
  })

  -- Initial scan
  on_lines()
end
