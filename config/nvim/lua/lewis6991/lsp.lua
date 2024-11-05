local api, lsp = vim.api, vim.lsp
local autocmd = api.nvim_create_autocmd

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
  autocmd('FileType', {
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
  --- @param x string
  --- @return string?
  local function match_require(x)
    return x:match('require') and (
      x:match("require%s*%(%s*'([^.']+).*'%)") or
      x:match('require%s*%(%s*"([^."]+).*"%)') or
      x:match("require%s*'([^.']+).*'%)") or
      x:match('require%s*"([^."]+).*"%)')
    )
  end

  --- @param client vim.lsp.Client
  --- @param bufnr integer
  local function auto_add_lua_libs(client, bufnr)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc') then
        -- Updates to settings are ingored if a .luarc.json is present
        return
      end
    end

    client.settings = vim.tbl_deep_extend('keep', client.settings, {
      Lua = { workspace = { library = {} } }
    })

    --- @param first? integer
    --- @param last? integer
    local function on_lines(first, last)
      local do_change = false

      local lines = api.nvim_buf_get_lines(bufnr, first or 0, last or -1, false)
      for _, line in ipairs(lines) do
        local m = match_require(line)
        if m then
          for _, mod in ipairs(vim.loader.find(m, { patterns = { '', '.lua' } })) do
            local lib = vim.fs.dirname(mod.modpath)
            local libs = client.settings.Lua.workspace.library
            if not vim.tbl_contains(libs, lib) then
              libs[#libs + 1] = lib
              do_change = true
            end
          end
        end
      end

      if do_change then
        client.notify('workspace/didChangeConfiguration', { settings = client.settings })
      end
    end

    api.nvim_buf_attach(bufnr, false, {
      on_lines = function(_, _, _, first, _, last)
        on_lines(first, last)
      end,
      on_reload = function()
        on_lines()
      end,
    })

    -- Initial scan
    on_lines()
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
    -- Note this is ignored if the project has a .luarc.json
    settings = {
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
    },
    on_attach = auto_add_lua_libs,
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
  autocmd('LspAttach', {
    callback = function(args)
      local client = assert(lsp.get_client_by_id(args.data.client_id))
      if client.supports_method('textDocument/codeLens') then
        lsp.codelens.refresh({bufnr = args.buf})
        autocmd({ 'FocusGained', 'WinEnter', 'BufEnter', 'CursorMoved' }, {
          callback = debounce(200, function(args0)
            lsp.codelens.refresh({bufnr = args0.buf})
          end)
        })
        -- Code lens setup, don't call again
        return true
      end
    end
  })
end

do -- textDocument/documentHighlight
  local method = 'textDocument/documentHighlight'

  autocmd({ 'FocusGained', 'WinEnter', 'BufEnter', 'CursorMoved' }, {
    callback = debounce(200, function(args)
      lsp.buf.clear_references()
      local win = api.nvim_get_current_win()
      local bufnr = args.buf --- @type integer
      for _, client in ipairs(lsp.get_clients({ bufnr = bufnr, method = method })) do
        local enc = client.offset_encoding
        client.request(
          method,
          lsp.util.make_position_params(0, enc),
          function(_, result, ctx)
            if not result or win ~= api.nvim_get_current_win() then
              return
            end
            lsp.util.buf_highlight_references(ctx.bufnr, result, enc)
          end,
          bufnr
        )
      end
    end)
  })

  autocmd({ 'FocusLost', 'WinLeave', 'BufLeave' }, {
    callback = lsp.buf.clear_references
  })
end

local function with(f, config)
  return function(c)
    return f(vim.tbl_deep_extend('force', config, c or {}))
  end
end

vim.lsp.buf.signature_help = with(vim.lsp.buf.signature_help, {
  border = 'rounded',
  title_pos = 'left',
})
