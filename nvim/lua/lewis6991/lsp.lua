local lsp_installer = require("nvim-lsp-installer")
local nvim_lsp = require 'lspconfig'

local M = {}

if "diagnostic config" then
  vim.diagnostic.config{
    severity_sort = true,
    update_in_insert = true,
  }

  local function set_lsp_sign(name, text)
    vim.fn.sign_define(name, {text = text, texthl = name})
  end

  set_lsp_sign("DiagnosticSignError", "✘")
  set_lsp_sign("DiagnosticSignWarn" , "!")
  set_lsp_sign("DiagnosticSignInfo" , "I")
  set_lsp_sign("DiagnosticSignHint" , "H")
end

if "handlers" then
  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
    vim.lsp.handlers.hover, {
      -- Use a sharp border with `FloatBorder` highlights
      border = "single"
    }
  )
end

local custom_on_attach = function(_, bufnr)
  local keymap = function(key, result)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', key, '<cmd>lua '..result..'<CR>', {noremap = true, silent = true})
  end

  keymap('<C-]>'     , 'vim.lsp.buf.definition()')
  keymap('K'         , 'vim.lsp.buf.hover()')
  keymap('gK'        , 'vim.lsp.buf.signature_help()')
  keymap('<C-s>'     , 'vim.lsp.buf.signature_help()')
  keymap('gr'        , 'vim.lsp.buf.references()')
  keymap('<leader>rn', 'vim.lsp.buf.rename()')
  keymap('<leader>ca', 'vim.lsp.buf.code_action()')
  keymap('<leader>e' , 'vim.lsp.diagnostic.show_line_diagnostics()')
  keymap(']d'        , 'vim.lsp.diagnostic.goto_next()')
  keymap('[d'        , 'vim.lsp.diagnostic.goto_prev()')
  keymap('go'        , 'vim.lsp.diagnostic.set_loclist()')


  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end

local function setup(config, opts)
  if not config then
    return
  end

  opts = opts or {}

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

local server_opts = {

  ["sumneko_lua"] = function()
    return require("lua-dev").setup{}
  end,

  ["diagnosticls"] = function()
    local linters = require'lewis6991.linters'
    return {
      filetypes = {'tcl', 'python', 'sh'},
      init_options = {
        filetypes = {
          python      = {'mypy'},
          -- sh          = {'shellcheck'},
          tcl         = {'tcl_lint'},
        },
        linters = (function()
          local r = vim.deepcopy(linters)
          for _, linter in pairs(r) do
            linter.on_attach = nil
          end
          return r
        end)()
      },
      on_attach = function(client, bufnr)
        local ft = vim.api.nvim_buf_get_option(bufnr, 'filetype')
        local filetypes = client.config.init_options.filetypes[ft]
        for name, linter in pairs(linters) do
          if linter.on_attach and filetypes and vim.tbl_contains(filetypes, name) then
            linter.on_attach(client, bufnr)
          end
        end
      end
    }
  end

}

if "teal-language-server" then
  -- Make sure this is a slash (as theres some metamagic happening behind the scenes)
  local configs = require("lspconfig/configs")
  local server = require "nvim-lsp-installer.server"
  local shell = require "nvim-lsp-installer.installers.shell"

  local name = "teal_language_server"

  configs[name] = {
    default_config = {
      cmd = {
        "teal-language-server",
        -- "logging=on", use this to enable logging in /tmp/teal-language-server.log
      },
      filetypes = { 'teal' },
      root_dir = nvim_lsp.util.root_pattern("tlconfig.lua", ".git"),
      settings = {},
    },
  }

  local tealls = server.Server:new {
    name = name,
    root_dir = server.get_server_root_path(name),
    installer = {shell.sh('luarocks install --dev teal-language-server')},
    default_options = {}
  }

  lsp_installer.register(tealls)
end

if "nvim-lsp-installer" then
  lsp_installer.on_server_ready(function(server)
    local opts = server_opts[server.name] and server_opts[server.name]()
    setup(server, opts)
    -- vim.cmd [[ do User LspAttachBuffers ]]
  end)

  local lsp_installer_servers = require'nvim-lsp-installer.servers'

  for _, server in ipairs{
    'jedi_language_server',
    'bashls',
    'vimls',
    'sumneko_lua',
    'diagnosticls',
    'teal_language_server',
  } do
    local ok, obj = lsp_installer_servers.get_server(server)
    if ok and not obj:is_installed() then
      obj:install()
    end
  end
end

if "metals" then
  M.setup_metals = function()
    local metals = require'metals'
    metals.initialize_or_attach(
      vim.tbl_deep_extend('force', metals.bare_config(), {
        init_options = {
          statusBarProvider = 'on'
        },
        settings = {
          showImplicitArguments = true,
        },
        on_attach = custom_on_attach
      })
    )
  end

  vim.cmd[[
    augroup metals_lsp
    au!
    au FileType scala,sbt lua require'lewis6991.lsp'.setup_metals()
    augroup END
  ]]
end

return M

-- vim: foldminlines=1 foldnestmax=1 :
