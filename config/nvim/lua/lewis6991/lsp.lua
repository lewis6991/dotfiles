local api, lsp = vim.api, vim.lsp
local autocmd = api.nvim_create_autocmd

--- @param cfg vim.lsp.Config
local function add(name, cfg)
  lsp.config(name, cfg)
  lsp.enable(name)
end

add('clangd', { -- clangd
  cmd = { 'clangd', '--clang-tidy' },
  root_markers = { '.clangd', 'compile_commands.json' },
  filetypes = { 'c', 'cpp' },
})

add('luals', {
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
    cmd = { pyright..'-langserver', '--stdio' },
    filetypes = { 'python' },
    root_markers = python_markers,
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
    root_markers = python_markers,
  })
end

-- install with:
--   npm i -g bash-language-server
-- also uses shellcheck if installed:
--   brew install shellcheck
add('bashls', {
  cmd = { 'bash-language-server', 'start' },
  filetypes = { 'sh' },
  settings = {
    bashIde = {
      shellcheckArguments = {
        '-e', 'SC2086', -- Double quote to prevent globbing and word splitting
        '-e', 'SC2155', -- Declare and assign separately to avoid masking return values
      },
    }
  }
})

-- install with:
--   npm install -g vscode-langservers-extracted
add('jsonls', {
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = { 'json', 'jsonc' }
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
      }
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

do -- trouble
  autocmd('LspAttach', {
    callback = function(args)
      vim.keymap.set('n', '<C-]>', "<cmd>Trouble lsp_definitions<cr>", { buffer = args.buf })
    end
  })
end

do -- textDocument/codelens
  autocmd('LspAttach', {
    callback = function(args)
      local client = assert(lsp.get_client_by_id(args.data.client_id))
      if client:supports_method('textDocument/codeLens') then
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
        client:request(
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

local function with(f, cfg)
  return function(c)
    return f(vim.tbl_deep_extend('force', cfg, c or {}))
  end
end

lsp.buf.signature_help = with(lsp.buf.signature_help, {
  border = 'rounded',
  title_pos = 'left',
})
