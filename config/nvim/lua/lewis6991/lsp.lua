
local M = {}

if "diagnostic config" then
  vim.diagnostic.config{
    severity_sort = true,
    update_in_insert = true,
  }

  local function set_lsp_sign(name, text)
    vim.fn.sign_define(name, {text = text, texthl = name})
  end

  vim.api.nvim_set_hl(0, 'LspCodeLens', {link='WarningMsg'})

  set_lsp_sign("DiagnosticSignError", "●")
  set_lsp_sign("DiagnosticSignWarn" , "●")
  set_lsp_sign("DiagnosticSignInfo" , "●")
  set_lsp_sign("DiagnosticSignHint" , "○")
end

local function custom_on_attach(client, bufnr)
  local function map(key, result, desc)
    vim.keymap.set('n', key, result, {silent = true, buffer=bufnr, desc=desc})
  end

  if client.resolved_capabilities.code_lens then
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

  -- Use LSP as the handler for omnifunc.
  --    See `:help omnifunc` and `:help ins-completion` for more information.
  vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

  require("aerial").setup{}
  require("aerial").on_attach(client, bufnr)
  map('<leader>a', '<cmd>AerialToggle!<CR>')
end

local server_opts = {
  ["sumneko_lua"] = function()
    return require("lua-dev").setup{
      library = {
        plugins = false
      }
    }
  end
}

local function setup(config, opts)
  if not config then
    return
  end

  local server_opts0 = server_opts[config.name] and server_opts[config.name]()

  opts = vim.tbl_deep_extend('force', opts or {}, server_opts0 or {})

  local on_attach = opts.on_attach
  opts.on_attach = function(client, bufnr)
    custom_on_attach(client, bufnr)
    if on_attach then
      on_attach(client, bufnr)
    end
  end

  opts.flags = vim.tbl_deep_extend('keep', opts.flags or {}, {
    debounce_text_changes = 200,
  })

  local has_cmp_lsp, cmp_lsp = pcall(require, 'cmp_nvm_lsp')
  if has_cmp_lsp then
    -- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
    opts.capabilities = vim.lsp.protocol.make_client_capabilities()
    opts.capabilities = cmp_lsp.update_capabilities(opts.capabilities)
  end

  config:setup(opts)
end

if "nvim-lsp-installer" then
  local lsp_installer = require("nvim-lsp-installer")
  lsp_installer.on_server_ready(setup)

  local lsp_installer_servers = require'nvim-lsp-installer.servers'

  for _, server in ipairs{
    'jedi_language_server',
    'bashls',
    'vimls',
    'sumneko_lua',
    'teal_language_server'
  } do
    local ok, obj = lsp_installer_servers.get_server(server)
    if ok and not obj:is_installed() then
      obj:install()
    end
  end
end

if "metals" then
  local setup_metals = function()
    local metals = require'metals'

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true

    metals.initialize_or_attach(vim.tbl_deep_extend('force', metals.bare_config(), {
      on_attach = custom_on_attach,
      capabilities = capabilities,
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

nvim_lsp.clangd.setup{
  on_attach = custom_on_attach
}

return M

-- vim: foldminlines=1 foldnestmax=1 :
