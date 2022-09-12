local api = vim.api
local lsp = vim.lsp

require'lsp_signature'.setup{
  hi_parameter = "Visual",
}

local function map(bufnr, key, result, desc)
  vim.keymap.set('n', key, result, {silent = true, buffer=bufnr, desc=desc})
end

local done_st = false

local on_attach_fns = {
  semantic_tokens = function(client, bufnr)
    if not done_st then
      require("nvim-semantic-tokens").setup {
        preset = "default",
        -- highlighters is a list of modules following the interface of nvim-semantic-tokens.table-highlighter or
        -- function with the signature: highlight_token(ctx, token, highlight) where
        --        ctx (as defined in :h lsp-handler)
        --        token  (as defined in :h vim.lsp.semantic_tokens.on_full())
        --        highlight (a helper function that you can call (also multiple times) with the determined highlight group(s) as the only parameter)
        highlighters = { require 'nvim-semantic-tokens.table-highlighter'}
      }
      api.nvim_create_augroup('SemanticTokens', {})
      done_st = true
    end

    local caps = client.server_capabilities
    if caps.semanticTokensProvider and caps.semanticTokensProvider.full then
      api.nvim_create_autocmd("TextChanged", {
        group = 'SemanticTokens',
        buffer = bufnr,
        callback = function()
          lsp.buf.semantic_tokens_full()
        end,
      })
      -- fire it first time on load as well
      lsp.buf.semantic_tokens_full()
    end
  end,

  mappings = function(_, bufnr)
    map(bufnr, '<C-]>'     , lsp.buf.definition, 'lsp.buf.definition'    )
    map(bufnr, '<leader>cl', lsp.codelens.run      , 'lsp.codelens.run'      )
    -- map(bufnr, 'K'         , lsp.buf.hover         , 'lsp.buf.hover'         )
    -- map(bufnr, 'gK'        , lsp.buf.signature_help, 'lsp.buf.signature_help')
    map(bufnr, '<C-s>'     , lsp.buf.signature_help, 'lsp.buf.signature_help')
    map(bufnr, '<leader>rn', lsp.buf.rename        , 'lsp.buf.rename'        )
    map(bufnr, '<leader>ca', lsp.buf.code_action   , 'lsp.buf.code_action'   )
    -- keymap(bufnr, 'gr'        , 'lsp.buf.references()')
    map(bufnr, 'gr', '<cmd>Trouble lsp_references<cr>')
    map(bufnr, 'gR', '<cmd>Telescope lsp_references layout_strategy=vertical<cr>')
  end,

  aerial = function(client, bufnr)
    local has_aerial, aerial = pcall(require, 'aerial')
    if has_aerial then
      aerial.setup{}
      aerial.on_attach(client, bufnr)
      map(bufnr, '<leader>a', '<cmd>AerialToggle!<CR>')
    end
  end,

  code_lens = function(client, bufnr)
    if client.server_capabilities.code_lens then
      api.nvim_create_autocmd({'BufEnter', 'CursorHold', 'InsertLeave'}, {
        buffer = bufnr,
        callback = lsp.codelens.refresh
      })
      lsp.codelens.refresh()
    end
  end

}

local function custom_on_attach(client, bufnr)
  for _, fn in pairs(on_attach_fns) do
    fn(client, bufnr)
  end
end

local server_opts = {
  sumneko_lua = function()
    local opts = require("lua-dev").setup{
      -- library = {
      --   plugins = false
      -- }
    }
    opts.settings.Lua.diagnostics = {
      globals = { 'it', 'describe', 'before_each', 'after_each', 'pending' }
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

  local has_cmp_lsp, cmp_lsp = pcall(require, 'cmp_nvm_lsp')
  if has_cmp_lsp then
    -- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
    opts.capabilities = lsp.protocol.make_client_capabilities()
    opts.capabilities = cmp_lsp.update_capabilities(opts.capabilities)
  end

  config.setup(opts)
end

require('mason').setup()
require('mason-lspconfig').setup{}

if "metals" then
  local function setup_metals()
    local metals = require'metals'

    metals.initialize_or_attach(vim.tbl_deep_extend('force', metals.bare_config(), {
      on_attach = custom_on_attach,
      handlers = {
        ["metals/status"] = function(_, status, ctx)
          lsp.handlers["$/progress"](_, {
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

  api.nvim_create_autocmd('FileType', {
    pattern = {'scala', 'sbt'},
    callback = setup_metals
  })
end

local nvim_lsp = require'lspconfig'

for _, server in ipairs{
  'clangd',
  'cmake',
  'sumneko_lua',
  'pyright',
  'cmake',
  'bashls',
  -- 'jedi_language_server',
} do
  setup(nvim_lsp[server])
end

-- vim: foldminlines=1 foldnestmax=1 :
