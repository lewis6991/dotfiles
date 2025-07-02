local api, lsp = vim.api, vim.lsp
local autocmd = api.nvim_create_autocmd

lsp.config('basedpyright', {
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = 'strict',
      },
    },
  },
})

lsp.config('bashls', {
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

local pyright = vim.fn.executable('basedpyright') == 1 and 'basedpyright' or 'pyright'

lsp.enable({
  'clangd',
  pyright,
  'emmylua',
  'luals',
  'ruff',
  'bashls',
  'tls',
  'jsonls',
  'rust_analyzer',
})

-- install with:
--   pip install tclint
lsp.config('tclsp', {
  cmd = { 'tclsp' },
  filetypes = { 'tcl' },
  root_markers = { 'tclint.toml' },
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

autocmd('LspAttach', {
  desc = 'Lsp codelens',
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

do -- textDocument/documentHighlight
  autocmd({ 'FocusGained', 'WinEnter', 'BufEnter', 'CursorMoved' }, {
    desc = 'Lsp: highlight references',
    callback = debounce(200, function(args)
      lsp.buf.clear_references()
      local win = api.nvim_get_current_win()
      local bufnr = args.buf --- @type integer
      local method = 'textDocument/documentHighlight'
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

require('gizmos.luals_setup')()

autocmd('LspAttach', {
  desc = 'Lsp: custom mappings',
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
