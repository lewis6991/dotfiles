local lspconfig = require('lspconfig')

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
  client.notify('workspace/didChangeConfiguration', { settings = config.settings })
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
        -- library = vim.api.nvim_get_runtime_file("", true)
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
    return true
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

-- install with:
--   npm install -g vscode-langservers-extracted
-- setup('jsonls')

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if client.supports_method('textDocument/codeLens') then
      vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
        buffer = args.buf,
        callback = vim.lsp.codelens.refresh,
      })
      vim.lsp.codelens.refresh()
    end
  end,
})

-- vim.api.nvim_create_autocmd('LspAttach', {
--   callback = function(args)
--     local client = vim.lsp.get_client_by_id(args.data.client_id)
--     client.server_capabilities.semanticTokensProvider = nil
--   end
-- })
