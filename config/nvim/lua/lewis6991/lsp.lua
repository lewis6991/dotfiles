local api, lsp = vim.api, vim.lsp

local lsp_group = api.nvim_create_augroup('lewis6991.lsp', {})

--- @class LspClientConfig : vim.lsp.ClientConfig
--- @field filetypes string[]
--- @field cmd string[]
--- @field markers? string[]
--- @field disable? boolean

--- @param name string
--- @param config LspClientConfig
local function add(name, config)
  if config.disable then
    return
  end
  config.name = name
  api.nvim_create_autocmd('FileType', {
    pattern = config.filetypes,
    group = lsp_group,
    callback = function(args)
      if vim.bo[args.buf].buftype == 'nofile' then
        return
      end

      config.capabilities = lsp.protocol.make_client_capabilities()

      config.capabilities =
        vim.tbl_deep_extend('force', config.capabilities, require('cmp_nvim_lsp').default_capabilities())

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

add('clangd', {
  cmd = { 'clangd', '--clang-tidy' },
  markers = { '.clangd', 'compile_commands.json' },
  filetypes = { 'c', 'cpp' },
})

add('lua_ls', {
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

local python_markers = {
  'pyproject.toml',
  'setup.py',
  'setup.cfg',
  'requirements.txt',
  'Pipfile',
  'pyrightconfig.json',
}

add('pyright', {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  markers = python_markers,
  settings = {
    -- needed to make it work
    python = {},
  },
})

add('ruff', {
  cmd = { 'ruff-lsp' },
  filetypes = { 'python' },
  markers = python_markers,
})

add('bashls', {
  cmd = { 'bash-language-server', 'start' },
  filetypes = { 'sh' }
})

-- install with:
--   npm install -g vscode-langservers-extracted
add('jsonls', {
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

--- @param fn fun(bufnr: integer, client: vim.lsp.Client)
local function lsp_attach(fn)
  api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
      local client = assert(lsp.get_client_by_id(args.data.client_id))
      fn(args.buf, client)
    end
  })
end

-- 'textDocument/codeLens'
lsp_attach(function(bufnr, client)
  if not client.supports_method('textDocument/codeLens') then
    return
  end

  api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
    buffer = bufnr,
    callback = function()
      lsp.codelens.refresh({bufnr = bufnr})
    end
  })
  lsp.codelens.refresh({bufnr = bufnr})
end)

-- 'textDocument/documentHighlight'
lsp_attach(function(bufnr, client)
  if not client.supports_method('textDocument/documentHighlight') then
    return
  end

  api.nvim_create_autocmd({ 'FocusGained', 'WinEnter', 'BufEnter', 'CursorMoved', 'CursorHold', 'CursorHoldI' }, {
    buffer = bufnr,
    callback = debounce(200, function()
      lsp.buf.clear_references()
      lsp.buf.document_highlight()
    end)
  })

  api.nvim_create_autocmd({ 'FocusLost', 'WinLeave', 'BufLeave' }, {
    buffer = bufnr,
    callback = lsp.buf.clear_references
  })
end)
