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

  opts.on_attach = opts.on_attach or custom_on_attach

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
setup(nvim_lsp.diagnosticls, {
  filetypes = {'Jenkinsfile', 'tcl', 'python', 'sh', 'teal'},
  init_options = {
    filetypes = {
      python      = {'pylint', 'mypy'},
      sh          = {'shellcheck'},
      teal        = {'tealcheck'},
      tcl         = {'tcl_lint'},
      Jenkinsfile = {'jenkinsfile_validate'}
    },
    linters = require'lewis6991.linters'
  }
})

vim.g.diagnostic_enable_virtual_text = 1
vim.g.diagnostic_enable_underline = 0
vim.g.diagnostic_virtual_text_prefix = ' '

local function set_lsp_sign(name, text)
  vim.fn.sign_define(name, {text = text, texthl = name})
end

set_lsp_sign("LspDiagnosticsSignError"      , "✘")
set_lsp_sign("LspDiagnosticsSignWarning"    , "!")
set_lsp_sign("LspDiagnosticsSignInformation", "I")
set_lsp_sign("LspDiagnosticsSignHint"       , "H")

function Lsp_status()
  if vim.tbl_isempty(vim.lsp.buf_get_clients(0)) then
    return ''
  end

  local status = {}

  for _, ty in ipairs { 'Warning', 'Error', 'Information', 'Hint' } do
    local n = vim.lsp.diagnostic.get_count(0, ty)
    if n > 0 then
      table.insert(status, ('%s:%s'):format(ty:sub(1,1), n))
    end
  end
  local r = table.concat(status, ' ')

  return r == '' and 'LSP' or r
end
