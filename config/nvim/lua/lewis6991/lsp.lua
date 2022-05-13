
local function custom_on_attach(client, bufnr)
  local function map(key, result, desc)
    vim.keymap.set('n', key, result, {silent = true, buffer=bufnr, desc=desc})
  end

  if client.server_capabilities.code_lens then
    vim.api.nvim_create_autocmd({'BufEnter', 'CursorHold', 'InsertLeave'}, {
      buffer = bufnr,
      callback = vim.lsp.codelens.refresh
    })
    vim.lsp.codelens.refresh()
  end

  map('<C-]>'     , vim.lsp.buf.definition    , 'vim.lsp.buf.definition'    )
  map('<leader>cl', vim.lsp.codelens.run      , 'vim.lsp.codelens.run'      )
  -- map('K'         , vim.lsp.buf.hover         , 'vim.lsp.buf.hover'         )
  -- map('gK'        , vim.lsp.buf.signature_help, 'vim.lsp.buf.signature_help')
  map('<C-s>'     , vim.lsp.buf.signature_help, 'vim.lsp.buf.signature_help')
  map('<leader>rn', vim.lsp.buf.rename        , 'vim.lsp.buf.rename'        )
  map('<leader>ca', vim.lsp.buf.code_action   , 'vim.lsp.buf.code_action'   )
  -- keymap('gr'        , 'vim.lsp.buf.references()')
  map('gr', '<cmd>Trouble lsp_references<cr>')

  local has_aerial, aerial = pcall(require, 'aerial')
  if has_aerial then
    aerial.setup{}
    aerial.on_attach(client, bufnr)
    map('<leader>a', '<cmd>AerialToggle!<CR>')
  end
end

local server_opts = {
  sumneko_lua = function()
    local opts = require("lua-dev").setup{
      library = {
        plugins = false
      }
    }
    opts.settings.Lua.diagnostics = {
      globals = { 'it', 'describe', 'before_each', 'after_each' }
    }
    return opts
  end
}

local function setup(config, opts)
  if not config then
    return
  end

  local server_opts0 = server_opts[config.name] and server_opts[config.name]()

  opts = vim.tbl_deep_extend('force', opts or {}, server_opts0 or {})

  opts.on_attach = custom_on_attach

  -- opts.flags = vim.tbl_deep_extend('keep', opts.flags or {}, {
  --   debounce_text_changes = 200,
  -- })

  local has_cmp_lsp, cmp_lsp = pcall(require, 'cmp_nvm_lsp')
  if has_cmp_lsp then
    -- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
    opts.capabilities = vim.lsp.protocol.make_client_capabilities()
    opts.capabilities = cmp_lsp.update_capabilities(opts.capabilities)
  end

  config.setup(opts)
end

require("nvim-lsp-installer").setup()

if "metals" then
  local function setup_metals()
    local metals = require'metals'

    metals.initialize_or_attach(vim.tbl_deep_extend('force', metals.bare_config(), {
      on_attach = custom_on_attach,
      handlers = {
        ["metals/status"] = function(_, status, ctx)
          vim.lsp.handlers["$/progress"](_, {
            token = 1,
            value = {
              kind = status.show and 'begin' or status.hide and 'end' or "report",
              message = status.text,
            }
          }, ctx)
        end
      },

      init_options = {
        statusBarProvider = 'on'
      },
      settings = {
        showImplicitArguments = true,
      }
    }))
  end

  vim.api.nvim_create_autocmd('FileType', {
    pattern = {'scala', 'sbt'},
    callback = setup_metals
  })
end

local nvim_lsp = require'lspconfig'

for _, server in ipairs{
  'clangd',
  'sumneko_lua',
  'jedi_language_server',
} do
  setup(nvim_lsp[server])
end

-- vim: foldminlines=1 foldnestmax=1 :
