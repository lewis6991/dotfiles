local lspconfig = require'lspconfig'

local function setup(name, user_config)
  user_config = user_config or {}
  user_config.on_setup = function(config)
    config.capabilities = vim.lsp.protocol.make_client_capabilities()
    vim.tbl_extend('force', config.capabilities, require('cmp_nvim_lsp').default_capabilities())
  end

  lspconfig[name].setup(user_config)
end

--- @param client lsp.Client
--- @param settings table
local function add_settings(client, settings)
  local config = client.config
  config.settings = vim.tbl_deep_extend('force', config.settings, settings)
  client.notify("workspace/didChangeConfiguration", { settings = config.settings })
end

local function default_lua_settings()
  return {
    Lua = {
      runtime = {
        version = 'LuaJIT'
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          "${3rd}/busted/library",
          "${3rd}/luv/library"
        }
        -- library = vim.api.nvim_get_runtime_file("", true)
      }
    }
  }
end

-- Clangd
setup('clangd', {
  cmd = { 'clangd', '--clang-tidy' },
})

-- LuaLS
setup('lua_ls', {
  on_init = function(client)
    local path = client.workspace_folders[1].name
    if not vim.uv.fs_stat(path..'/.luarc.json') and not vim.uv.fs_stat(path..'/.luarc.jsonc') then
      add_settings(client, default_lua_settings())
    end
    return true
  end,
  settings = {
    Lua = {
      hint = {
        enable = true,
        paramName = 'Literal',
        setType = true
      }
    }
  }
})

setup('pyright')
setup('ruff_lsp')
setup('bashls')

-- install with:
--   npm install -g vscode-langservers-extracted
-- setup('jsonls')

-- vim.api.nvim_create_autocmd('LspAttach', {
--   callback = function(args)
--     local client = vim.lsp.get_client_by_id(args.data.client_id)
--     client.server_capabilities.semanticTokensProvider = nil
--   end
-- })


do -- fswatch

  local FSWATCH_EVENTS = {
    Created = 1,
    Updated = 2,
    Removed = 3,
    -- Renamed
    OwnerModified = 2,
    AttributeModified = 2,
    MovedFrom = 1,
    MovedTo = 3,
    -- IsFile
    IsDir = false,
    IsSymLink = false,
    PlatformSpecific = false,
    -- Link
    -- Overflow
  }

  --- @param data string
  --- @param opts table
  --- @param callback fun(path: string, event: integer)
  local function fswatch_output_handler(data, opts, callback)
    local d = vim.split(data, '%s+')
    local cpath = d[1]

    for i = 2, #d do
      if FSWATCH_EVENTS[d[i]] == false then
        return
      end
    end

    if opts.include_pattern and opts.include_pattern:match(cpath) == nil then
      return
    end

    if opts.exclude_pattern and opts.exclude_pattern:match(cpath) ~= nil then
      return
    end

    for i = 2, #d do
      local e = FSWATCH_EVENTS[d[i]]
      if e then
        callback(cpath, e)
      end
    end
  end

  local function fswatch(path, opts, callback)
    local obj = vim.system({
      'fswatch',
      '--recursive',
      '--event-flags',
      '--exclude', '/.git/',
      path
    }, {
      stdout = function(err, data)
        if err then
          error(err)
        end

        if not data then
          return
        end

        for line in vim.gsplit(data, '\n', { plain = true, trimempty = true }) do
          fswatch_output_handler(line, opts, callback)
        end
      end
    })

    return function()
      obj:kill(2)
    end
  end

  if vim.fn.executable('fswatch') == 1 then
    require('vim.lsp._watchfiles')._watchfunc = fswatch
  end
end
