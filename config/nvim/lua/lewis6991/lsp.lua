local api, lsp = vim.api, vim.lsp
local get_clients = vim.lsp.get_clients

local lsp_group = api.nvim_create_augroup('lewis6991.lsp', {})

--- @class LspClientConfig : vim.lsp.ClientConfig
--- @field name string
--- @field filetypes string[]
--- @field cmd string[]
--- @field markers? string[]
--- @field disable? boolean
--- @field on_setup? fun(capabilities: lsp.ClientCapabilities)

--- @param config LspClientConfig
local function setup(config)
  if config.disable then
    return
  end
  api.nvim_create_autocmd('FileType', {
    pattern = config.filetypes,
    group = lsp_group,
    callback = function(args)
      if vim.bo[args.buf].buftype == 'nofile' then
        return
      end

      local capabilities = lsp.protocol.make_client_capabilities()

      if vim.uv.os_uname().sysname == 'Linux' then
        capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false
      end

      if config.on_setup then
        config.on_setup(capabilities)
      end

      config.capabilities =
        vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      config.markers = config.markers or {}
      table.insert(config.markers, '.git')

      config.root_dir = vim.fs.root(args.buf, config.markers)
      vim.lsp.start(config)
    end,
  })
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
        -- library = api.nvim_get_runtime_file('', true)
      },
    },
  }
end

local function client_complete()
  --- @param c vim.lsp.Client
  --- @return string
  return vim.tbl_map(function(c)
    return c.name
  end, get_clients())
end

api.nvim_create_user_command('LspRestart', function(kwargs)
  local bufnr = vim.api.nvim_get_current_buf()
  local name = kwargs.fargs[1] --- @type string
  for _, client in ipairs(get_clients({ bufnr = bufnr, name = name })) do
    local bufs = vim.deepcopy(client.attached_buffers)
    client.stop()
    vim.wait(30000, function()
      return lsp.get_client_by_id(client.id) == nil
    end)
    local client_id = lsp.start_client(client.config)
    if client_id then
      for buf in pairs(bufs) do
        lsp.buf_attach_client(buf, client_id)
      end
    end
  end
end, {
  nargs = '*',
  complete = client_complete,
})

api.nvim_create_user_command('LspStop', function(kwargs)
  local bufnr = vim.api.nvim_get_current_buf()
  local name = kwargs.fargs[1] --- @type string
  for _, client in ipairs(get_clients({ bufnr = bufnr, name = name })) do
    client.stop()
  end
end, {
  nargs = '*',
  complete = client_complete,
})

setup({
  name = 'clangd',
  cmd = { 'clangd', '--clang-tidy' },
  markers = { '.clangd', 'compile_commands.json' },
  filetypes = { 'c', 'cpp' },
})

setup({
  name = 'lua_ls',
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  markers = {
    '.luarc.json',
    '.luarc.jsonc',
    '.luacheckrc',
    '.stylua.toml',
    'stylua.toml',
    'selene.toml',
    'selene.yml',
  },
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if not vim.uv.fs_stat(path .. '/.luarc.json') and not vim.uv.fs_stat(path .. '/.luarc.jsonc') then
        client.settings = vim.tbl_deep_extend('force', client.settings, default_lua_settings())
        client.notify('workspace/didChangeConfiguration', { settings = client.settings })
      end
    else
      client.settings = vim.tbl_deep_extend('force', client.settings, default_lua_settings())
      client.notify('workspace/didChangeConfiguration', { settings = client.settings })
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

setup({
  name = 'pyright',
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  markers = {
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    'Pipfile',
    'pyrightconfig.json',
  },
  settings = {
    -- needed to make it work
    python = {},
  },
})

setup({
  name = 'bashls',
  cmd = { 'bash-language-server', 'start' },
  filetypes = { 'sh' }
})

-- install with:
--   npm install -g vscode-langservers-extracted
setup({
  name = 'jsonls',
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = { 'json', 'jsonc' }
})

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
        callback = function()
          lsp.codelens.refresh({bufnr = args.buf})
        end
      })
      lsp.codelens.refresh({bufnr = args.buf})
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
