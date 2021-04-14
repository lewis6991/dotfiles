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

  if not opts.on_attach then
    opts.on_attach = custom_on_attach
  end

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
  filetypes = {'python', 'sh', 'teal'},
  init_options = {
    filetypes = {
      python = {'pylint', 'mypy'},
      sh     = {'shellcheck'},
      teal   = {'tealcheck'}
    },
    linters = {
      pylint = {
        sourceName = "pylint",
        command = "pylint",
        args = {"--output-format=json", '--from-stdin', '%filepath'},
        rootPatterns = {"pylintrc", "pyproject.toml", ".git"},
        parseJson = {
          line       = 'line',
          column     = 'column',
          security   = 'type',
          message    = '${message-id}: ${message}'
        },
        offsetColumn = 1,
        securities = {
          informational = "hint",
          refactor      = "info",
          convention    = "warning",
          warning       = "warning",
          error         = "error",
          fatal         = "error"
        },
      },
      mypy = {
        offsetColumn = 0,
        sourceName = "mypy",
        command = "mypy",
        args = {'--shadow-file', '%filepath', '%tempfile', '%filepath', '--strict'},
        rootPatterns = {"setup.cfg", ".git"},
        formatLines = 1,
        formatPattern = {
          '^([^:]+):(\\d+): ([^:]+): (.*)$',
          {
            sourceName = 1,
            sourceNameFilter = true,
            line = 2,
            security = 3,
            message = 4
          }
        },
        securities = {
          error = "error",
        },
      },
      tealcheck = {
        sourceName = "tealcheck",
        command = "tl",
        args = {'check', '%file'},
        isStdout = false,
        isStderr = true,
        rootPatterns = {"tlconfig.lua", ".git"},
        formatPattern = {
          '^([^:]+):(\\d+):(\\d+): (.+)$',
          {
            sourceName = 1,
            sourceNameFilter = true,
            line = 2,
            column = 3,
            message = 4
          }
        }
      },
      shellcheck = {
        sourceName = "shellcheck",
        command = "shellcheck",
        args = {'--shell=bash', '-f', 'json', '--exclude=1004,1091,2002,2016', '-'},
        parseJson = {
          line       = 'line',
          endLine    = 'endLine',
          column     = 'column',
          endColumn  = 'endColumn',
          security   = 'level',
          message    = '${message} [${code}]'
        },
        securities = {
          error   = "error",
          warning = "warning",
          info    = "info",
          hint    = "style",
        },
      }
    }
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
