local api, lsp = vim.api, vim.lsp
local autocmd = api.nvim_create_autocmd

local lsp_group = api.nvim_create_augroup('lewis6991.lsp', {})

--- @class LspClientConfig : vim.lsp.ClientConfig
--- @field filetypes string[]
--- @field markers? string[]

--- @param cfg LspClientConfig
local function config(cfg)
  autocmd('FileType', {
    pattern = cfg.filetypes,
    group = lsp_group,
    callback = function(args)
      local bufnr = args.buf
      if vim.bo[bufnr].buftype == 'nofile' then
        return
      end

      if vim.fn.executable(cfg.cmd[1]) == 0 then
        return
      end

      cfg.markers = cfg.markers or {}
      table.insert(cfg.markers, '.git')
      cfg.root_dir = vim.fs.root(bufnr, cfg.markers)

      vim.lsp.start(cfg)
    end,
  })
end

config({ -- clangd
  name = 'clangd',
  cmd = { 'clangd', '--clang-tidy' },
  markers = { '.clangd', 'compile_commands.json' },
  filetypes = { 'c', 'cpp' },
})

do -- Lua
  config({
    name = 'luals',
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
    on_attach = function(client, bufnr)
      require('lewis6991.lsp.auto_lua_require')(client, bufnr)
    end,
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

  config({
    name = pyright,
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
  config({
    name = 'ruff',
    cmd = { 'ruff-lsp' },
    filetypes = { 'python' },
    markers = python_markers,
  })
end

-- install with:
--   npm i -g bash-language-server
-- also uses shellcheck if installed:
--   brew install shellcheck
config({ -- bashls
  name = 'bashls',
  cmd = { 'bash-language-server', 'start' },
  filetypes = { 'sh' }
})

-- install with:
--   npm install -g vscode-langservers-extracted
config({ -- jsonls
  name = 'jsonls',
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
          vim.lsp.handlers['$/progress'](_, {
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

do -- cmp capablities
  -- commitCharactersSupport = true
  -- preselectSupport = true
  -- contextSupport = true
  -- insertTextMode = 1
  -- completionList.itemDefaults.commitCharacters
  -- resolveSupport
  -- insertReplaceSupport
  -- insertTextModeSupport
  -- labelDetailsSupport
  local mk_cap = lsp.protocol.make_client_capabilities
  lsp.protocol.make_client_capabilities = function()
    local has_cmp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
    if not has_cmp then
      return mk_cap()
    end

    return vim.tbl_deep_extend(
      'force',
      mk_cap(),
      cmp_nvim_lsp.default_capabilities()
    )
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

local function with(f, cfg)
  return function(c)
    return f(vim.tbl_deep_extend('force', cfg, c or {}))
  end
end

vim.lsp.buf.signature_help = with(vim.lsp.buf.signature_help, {
  border = 'rounded',
  title_pos = 'left',
})
