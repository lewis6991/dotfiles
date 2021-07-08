local nvim_lsp = require 'lspconfig'

local keymap = function(mode, key, result)
  vim.api.nvim_buf_set_keymap(0, mode, key, result, {noremap = true, silent = true})
end

local custom_on_attach = function()
  keymap('n', '<C-]>'     , '<cmd>lua vim.lsp.buf.definition()<CR>')
  keymap('n', 'K'         , '<cmd>lua vim.lsp.buf.hover()<CR>')
  keymap('n', 'gK'        , '<cmd>lua vim.lsp.buf.signature_help()<CR>')
  keymap('n', 'gr'        , '<cmd>lua vim.lsp.buf.references()<CR>')
  keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')
  keymap('n', ']d'        , '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>')
  keymap('n', '[d'        , '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>')
  keymap('n', 'go'        , '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>')

  vim.bo.omnifunc = 'v:lua.vim.lsp.omnifunc'
end

local function executable(path)
  return vim.fn.executable(path) == 1
end

local function setup(config, opts)
  opts = opts or {}

  local cmd = opts.cmd or config.document_config.default_config.cmd

  if not cmd or not executable(cmd[1]) then
    print(('%s is not installed'):format(config.name))
    return
  end

  local opts_on_attach = opts.on_attach
  opts.on_attach = function(client, bufnr)
    custom_on_attach(client, bufnr)
    if opts_on_attach then
      opts_on_attach(client, bufnr)
    end
  end

  opts.flags = opts.flags or {}
  opts.flags.debounce_text_changes = opts.flags.debounce_text_changes or 400

  config.setup(opts)
end

local function setup_sumneko_ls()
  local system_name
  if vim.fn.has("mac") == 1 then
    system_name = "macOS"
  elseif vim.fn.has("unix") == 1 then
    system_name = "Linux"
  else
    print("Unsupported system for sumneko")
  end

  local sumneko_root_path = '/Users/lewis/projects/lua-language-server'
  local sumneko_binary = sumneko_root_path.."/bin/"..system_name.."/lua-language-server"

  setup(nvim_lsp.sumneko_lua, {
    cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"};
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
          path = vim.split(package.path, ';'),
        },
        diagnostics = {
          globals = {
            -- Neovim
            "vim",
            -- Busted
            "describe", "it", "before_each", "after_each", "teardown", "pending"
          }
        },
        workspace = {
          library = {
            [vim.fn.expand('$VIMRUNTIME/lua')] = true,
            [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
          },
        },
      },
    },
  })
end

-- npm install -g vim-language-server
setup(nvim_lsp.vimls)

-- npm install -g bash-language-server
setup(nvim_lsp.bashls)

-- pip3 install jedi-language-server
setup(nvim_lsp.jedi_language_server)

-- https://github.com/sumneko/lua-language-server/wiki/Build-and-Run-(Standalone)
setup_sumneko_ls()

-- npm install -g diagnostic-languageserver
local linters = require'lewis6991.linters'

setup(nvim_lsp.diagnosticls, {
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
})

vim.g.diagnostic_enable_virtual_text = 1
vim.g.diagnostic_enable_underline = 1
vim.g.diagnostic_virtual_text_prefix = ' '

local function set_lsp_sign(name, text)
  vim.fn.sign_define(name, {text = text, texthl = name})
end

set_lsp_sign("LspDiagnosticsSignError"      , "✘")
set_lsp_sign("LspDiagnosticsSignWarning"    , "!")
set_lsp_sign("LspDiagnosticsSignInformation", "I")
set_lsp_sign("LspDiagnosticsSignHint"       , "H")

-- Enables logging to $XDG_CACHE_HOME/nvim/lsp.log
-- vim.lsp.set_log_level('trace')
