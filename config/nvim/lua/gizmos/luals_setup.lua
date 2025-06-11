local api = vim.api

local function default_settings()
  return {
    Lua = {
      runtime = {
        version = 'LuaJIT',
        path = { 'lua/?.lua', 'lua/?/init.lua' },
        pathStrict = true,
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          '${3rd}/busted/library',
        },
      },
      diagnostics = {
        groupFileStatus = {
          strict = 'Opened',
          strong = 'Opened',
        },
        groupSeverity = {
          strong = 'Warning',
          strict = 'Warning',
        },
        unusedLocalExclude = { '_*' },
      },
    },
  }
end

--- @param x string
--- @return string?
local function get_module(x)
  return x:match('require')
      and (
        x:match("require%s*%(%s*'([^./']+).*'%s*%)") -- require('<module>')
        or x:match('require%s*%(%s*"([^./"]+).*"%s*%)') -- require("<module>")
        or x:match("require%s*'([^./']+).*'%s*%)") -- require '<module>'
        or x:match('require%s*"([^./"]+).*"%s*%)') -- require "<module>"
        or x:match("pcall%s*%(%s*require%s*,%s*'([^./']+).*'%s*%)") -- pcall(require, "<module>")
        or x:match('pcall%s*%(%s*require%s*,%s*"([^./"]+).*"%s*%)') -- pcall(require, "<module>")
      )
    or x:match('@module')
      and (
        x:match('$-$-$-%s*@module%s*"([^./"]+).*"') -- @module "<module>"
        or x:match("$-$-$-%s*@module%s*'([^./']+).*'") -- @module '<module>'
      )
end

--- @param client vim.lsp.Client
--- @param bufnr integer
local function attach(client, bufnr)
  local local_ws = nil
  if client.workspace_folders then
    local path = client.workspace_folders[1].name
    local_ws = vim.fs.joinpath(path, 'lua')
    if vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc') then
      -- Updates to settings are ignored if a .luarc.json is present
      return
    end
  end

  -- Setup default settings
  client.settings = vim.tbl_deep_extend('keep', client.settings, default_settings())
  client:notify('workspace/didChangeConfiguration', { settings = client.settings })

  --- @param first? integer
  --- @param last? integer
  local function on_lines(_, _, _, first, _, last)
    local did_change = false
    local settings = client.settings

    local lines = api.nvim_buf_get_lines(bufnr, first or 0, last or -1, false)
    for _, line in ipairs(lines) do
      local m = get_module(line)
      if m then
        for _, mod in ipairs(vim.loader.find(m, { patterns = { '', '.lua' } })) do
          local lib = vim.fs.dirname(mod.modpath)
          --- @type string[]
          --- @diagnostic disable-next-line: undefined-field
          local libs = settings.Lua.workspace.library
          if lib ~= local_ws and not vim.tbl_contains(libs, lib) then
            -- print('ADDING ', lib)
            libs[#libs + 1] = lib
            did_change = true
          end
        end
      end
    end

    if did_change then
      client:notify('workspace/didChangeConfiguration', { settings = settings })
    end
  end

  api.nvim_buf_attach(bufnr, false, {
    on_lines = on_lines,
    on_reload = on_lines,
  })

  -- Initial scan
  on_lines()
end

--- @param luals_name? string
return function(luals_name)
  luals_name = luals_name or 'luals'
  api.nvim_create_autocmd('LspAttach', {
    desc = 'Lsp: luals setup',
    callback = function(args)
      local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
      if client.name == luals_name then
        attach(client, args.buf)
      end
    end,
  })
end
