local api, lsp = vim.api, vim.lsp

local lspconfig = require('lspconfig')

--- @class LspClientConfig : vim.lsp.ClientConfig
--- @field cmd? string[]

--- @param name string
--- @param user_config? LspClientConfig
local function setup(name, user_config)
  user_config = user_config or {}
  local capabilities = lsp.protocol.make_client_capabilities()
  user_config.capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
  lspconfig[name].setup(user_config)
end

--- @param client vim.lsp.Client
--- @param settings table
local function add_settings(client, settings)
  client.settings = vim.tbl_deep_extend('force', client.settings, settings)
  client.notify('workspace/didChangeConfiguration', { settings = client.settings })
end

local function default_lua_settings()
  return {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          '${3rd}/busted/library',
          '${3rd}/luv/library',
        },
        -- library = api.nvim_get_runtime_file("", true)
      },
    },
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
    if
      not vim.uv.fs_stat(path .. '/.luarc.json') and not vim.uv.fs_stat(path .. '/.luarc.jsonc')
    then
      add_settings(client, default_lua_settings())
    end
  end,
  settings = {
    Lua = {
      hint = {
        enable = true,
        paramName = 'Literal',
        setType = true,
      },
    },
  },
})

setup('pyright')
setup('ruff_lsp')
setup('bashls')

local function debounce(ms, fn)
  local timer = assert(vim.uv.new_timer())
  return function(...)
    local argc, argv = select('#', ...), { ... }
    timer:start(ms, 0, function()
      timer:stop()
      vim.schedule(function()
        fn(unpack(argv, 1, argc))
      end)
    end)
  end
end

-- install with:
--   npm install -g vscode-langservers-extracted
-- setup('jsonls')

api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = assert(lsp.get_client_by_id(args.data.client_id))

    if client.supports_method('textDocument/codeLens') then
      api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
        buffer = args.buf,
        callback = lsp.codelens.refresh,
      })
      lsp.codelens.refresh()
    end

    if client.supports_method('textDocument/documentHighlight') then
      api.nvim_create_autocmd({ 'FocusGained', 'WinEnter', 'BufEnter', 'CursorMoved', 'CursorHold', 'CursorHoldI' }, {
        buffer = args.buf,
        callback = debounce(200, function()
          lsp.buf.clear_references()
          lsp.buf.document_highlight()
        end)
      })
      api.nvim_create_autocmd({ 'FocusLost', 'WinLeave', 'BufLeave' }, {
        buffer = args.buf,
        callback = lsp.buf.clear_references
      })
    end
  end,
})

-- api.nvim_create_autocmd('LspAttach', {
--   callback = function(args)
--     local client = lsp.get_client_by_id(args.data.client_id)
--     client.server_capabilities.semanticTokensProvider = nil
--   end
-- })
