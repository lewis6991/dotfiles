local api, lsp = vim.api, vim.lsp
local autocmd = api.nvim_create_autocmd

--- @param cfg vim.lsp.Config
local function add(name, cfg)
  lsp.config(name, cfg)
  lsp.enable(name)
end

-- local js_filetypes = {
--   'javascript',
--   'javascriptreact',
--   'javascript.jsx',
--   'typescript',
--   'typescriptreact',
--   'typescript.tsx',
-- }
--
-- add('tls', {
--   cmd = { 'typescript-language-server', '--stdio' },
--   filetypes = js_filetypes,
--   root_markers = {'tsconfig.json', 'jsconfig.json', 'package.json', '.git'},
-- })
--
-- add('eslint', {
--   cmd = { 'vscode-eslint-language-server', '--stdio' },
--   filetypes = js_filetypes,
--   root_markers = { 'eslint.config.ts' },
--   -- Refer to https://github.com/Microsoft/vscode-eslint#settings-options for documentation.
--   settings = {
--     useESLintClass = false,
--     experimental = {
--       useFlatConfig = true,
--     },
--     -- format = true,
--     quiet = false,
--     run = 'onType',
--     -- nodePath configures the directory in which the eslint server should start its node_modules resolution.
--     -- This path is relative to the workspace folder (root dir) of the server instance.
--     nodePath = '.',
--   },
--   handlers = {
--     ['eslint/openDoc'] = function(_, result)
--       if not result then
--         return
--       end
--       local sysname = vim.uv.os_uname().sysname
--       if sysname:match 'Windows' then
--         os.execute(string.format('start %q', result.url))
--       elseif sysname:match 'Linux' then
--         os.execute(string.format('xdg-open %q', result.url))
--       else
--         os.execute(string.format('open %q', result.url))
--       end
--       return {}
--     end,
--     ['eslint/confirmESLintExecution'] = function(_, result)
--       if not result then
--         return
--       end
--       return 4 -- approved
--     end,
--     ['eslint/probeFailed'] = function()
--       vim.notify('[lspconfig] ESLint probe failed.', vim.log.levels.WARN)
--       return {}
--     end,
--     ['eslint/noLibrary'] = function()
--       vim.notify('[lspconfig] Unable to find ESLint library.', vim.log.levels.WARN)
--       return {}
--     end,
--   }
-- })

add('clangd', { -- clangd
  cmd = { 'clangd', '--clang-tidy' },
  root_markers = { '.clangd', 'compile_commands.json' },
  filetypes = { 'c', 'cpp' },
})

lsp.config('emmylua', {
  cmd = { 'emmylua_ls' },
  -- cmd = {
  --   '/Users/lewrus01/projects/emmylua-analyzer-rust/target/release/emmylua_ls',
  --    -- '--log-level', 'debug',
  -- },
  filetypes = { 'lua' },
  root_markers = {
    '.luarc.json',
    '.emmyrc.json',
  }
})

lsp.config('luals', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = {
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
  on_attach = function(client, bufnr)
    require('lewis6991.lsp.auto_lua_require')(client, bufnr)
  end,
})

lsp.enable(vim.env.EMMY and 'emmylua' or 'luals')

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

  add(pyright, {
    cmd = { pyright .. '-langserver', '--stdio' },
    filetypes = { 'python' },
    root_markers = python_markers,
    settings = {
      basedpyright = {
        analysis = {
          typeCheckingMode = 'strict',
        },
      },
    },
  })

  -- pip install ruff-lsp
  add('ruff', {
    cmd = { 'ruff', 'server' },
    filetypes = { 'python' },
    root_markers = python_markers,
  })
end

-- install with:
--   npm i -g bash-language-server
-- also uses shellcheck if installed:
--   brew install shellcheck
add('bashls', {
  cmd = { 'bash-language-server', 'start' },
  filetypes = { 'zsh', 'sh', 'bash' },
  settings = {
    bashIde = {
      shellcheckArguments = {
        '-e',
        'SC2086', -- Double quote to prevent globbing and word splitting
        '-e',
        'SC2155', -- Declare and assign separately to avoid masking return values
      },
    },
  },
})

-- install with:
--   npm install -g vscode-langservers-extracted
add('jsonls', {
  cmd = { 'vscode-json-language-server', '--stdio' },
  -- root_markers = { '.git' },
  filetypes = { 'json', 'jsonc' },
})

do -- metals
  local function setup_metals()
    local ok, metals = pcall(require, 'metals')
    if not ok then
      return
    end

    metals.initialize_or_attach(vim.tbl_deep_extend('force', metals.bare_config(), {
      handlers = {
        ['metals/status'] = function(_, status, ctx)
          lsp.handlers['$/progress'](_, {
            token = 1,
            value = {
              kind = status.show and 'begin' or status.hide and 'end' or 'report',
              message = status.text,
            },
          }, ctx)
        end,
      },

      init_options = {
        statusBarProvider = 'on',
      },
      settings = {
        showInferredType = true,
        showImplicitArguments = true,
        enableSemanticHighlighting = true,
      },
    }))
  end

  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'scala', 'sbt' },
    callback = setup_metals,
  })
end

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
      if client:supports_method('textDocument/codeLens') then
        lsp.codelens.refresh({ bufnr = args.buf })
        autocmd({ 'FocusGained', 'WinEnter', 'BufEnter', 'CursorMoved' }, {
          callback = debounce(200, function(args0)
            lsp.codelens.refresh({ bufnr = args0.buf })
          end),
        })
        -- Code lens setup, don't call again
        return true
      end
    end,
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
        client:request(method, lsp.util.make_position_params(0, enc), function(_, result, ctx)
          if not result or win ~= api.nvim_get_current_win() then
            return
          end
          lsp.util.buf_highlight_references(ctx.bufnr, result, enc)
        end, bufnr)
      end
    end),
  })

  autocmd({ 'FocusLost', 'WinLeave', 'BufLeave' }, {
    callback = lsp.buf.clear_references,
  })
end

local function with(f, cfg)
  return function(c)
    return f(vim.tbl_deep_extend('force', cfg, c or {}))
  end
end

lsp.buf.signature_help = with(lsp.buf.signature_help, {
  border = 'rounded',
  title_pos = 'left',
})

autocmd('LspAttach', {
  desc = 'lsp mappings',
  callback = function(args)
    local bufnr = args.buf --- @type integer
    vim.keymap.set(
      'n',
      '<M-]>',
      lsp.buf.type_definition,
      { desc = 'lsp.buf.type_definition', buffer = bufnr }
    )

    vim.keymap.set('n', '<M-i>', function()
      lsp.inlay_hint.enable(not lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
    end, { desc = 'lsp.buf.inlay_hint', buffer = bufnr })

    vim.keymap.set(
      'n',
      '<leader>cl',
      lsp.codelens.run,
      { desc = 'lsp.codelens.run', buffer = bufnr }
    )
  end,
})
