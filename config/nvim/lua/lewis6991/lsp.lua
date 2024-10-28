local api, lsp = vim.api, vim.lsp

local lsp_group = api.nvim_create_augroup('lewis6991.lsp', {})

--- @class LspClientConfig : vim.lsp.ClientConfig
--- @field filetypes string[]
--- @field markers? string[]

--- @param bufnr integer
--- @param config LspClientConfig
local function lsp_start(bufnr, config)
  if vim.bo[bufnr].buftype == 'nofile' then
    return
  end

  if vim.fn.executable(config.cmd[1]) == 0 then
    return
  end

  config.capabilities = lsp.protocol.make_client_capabilities()

  config.capabilities = vim.tbl_deep_extend(
    'force',
    config.capabilities,
    require('cmp_nvim_lsp').default_capabilities()
  )

  vim.keymap.set('n', '<C-]>', "<cmd>Trouble lsp_definitions<cr>", { buffer = bufnr })

  config.markers = config.markers or {}
  table.insert(config.markers, '.git')
  config.root_dir = vim.fs.root(bufnr, config.markers)

  vim.lsp.start(config)
end

--- @param name string
--- @param config LspClientConfig
local function add(name, config)
  config.name = name
  api.nvim_create_autocmd('FileType', {
    pattern = config.filetypes,
    group = lsp_group,
    callback = function(args)
      lsp_start(args.buf, config)
    end,
  })
end

add('clangd', {
  cmd = { 'clangd', '--clang-tidy' },
  markers = { '.clangd', 'compile_commands.json' },
  filetypes = { 'c', 'cpp' },
})

do -- Lua
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
        },
      },
    }
  end

  --- @param client vim.lsp.Client
  --- @return boolean
  local function use_default_lua_settings(client)
    if not client.workspace_folders then
      return true
    end

    local path = client.workspace_folders[1].name
    if vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc') then
      return true
    end

    return false
  end

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
      if use_default_lua_settings(client) then
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
end

do -- Python
  local python_markers = {
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    'Pipfile',
    'pyrightconfig.json',
  }

  -- pip install basedpyright
  local pyright = vim.fn.executable('basedpyright') == 1 and 'basedpyright' or 'pyright'

  add('pyright', {
    cmd = { pyright..'-langserver', '--stdio' },
    filetypes = { 'python' },
    markers = python_markers,
    settings = {
      basedpyright = {
        analysis = {
          typeCheckingMode = 'strict',
        }
      }
    }
  })

  -- pip install ruff-lsp
  add('ruff', {
    cmd = { 'ruff-lsp' },
    filetypes = { 'python' },
    markers = python_markers,
  })
end

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

do -- textDocument/codelens
  api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
      local client = assert(lsp.get_client_by_id(args.data.client_id))
      if client.supports_method('textDocument/codeLens') then
        lsp.codelens.refresh({bufnr = args.buf})
        api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
          callback = function(args0)
            lsp.codelens.refresh({bufnr = args0.buf})
          end
        })
      end
    end
  })
end

do -- textDocument/documentHighlight
  local method = 'textDocument/documentHighlight'

  api.nvim_create_autocmd({ 'FocusGained', 'WinEnter', 'BufEnter', 'CursorMoved', 'CursorHold', 'CursorHoldI' }, {
    callback = debounce(200, function(args)
      lsp.buf.clear_references()
      local bufnr = args.buf --- @type integer
      for _, client in ipairs(lsp.get_clients({ bufnr = bufnr })) do
        if client.supports_method(method, { bufnr = bufnr }) then
          local params = lsp.util.make_position_params()
          client.request(method, params, nil, bufnr)
        end
      end
    end)
  })

  api.nvim_create_autocmd({ 'FocusLost', 'WinLeave', 'BufLeave' }, {
    callback = lsp.buf.clear_references
  })
end
