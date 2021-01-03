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
          globals = {'vim'},
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

-- setup(nvim_lsp.diagnosticls, {
--   root_dir = nvim_lsp.util.root_pattern("pylintrc", "setup.cfg", ".git"),
--   filetypes = {"python"},
--   init_options = {
--     filetypes = {
--       python = "pylint"
--     },
--     linters = {
--       pylint = {
--         sourceName = "pylint",
--         command = "pylint",
--         args = {
--           "--output-format", "text",
--           "--score"        , "no",
--           "--msg-template" , "'{line}:{column}:{category}:{msg} ({msg_id}:{symbol})'",
--           "%file"
--         },
--         formatPattern = {
--           "^(\\d+?):(\\d+?):([a-z]+?):(.*)$",
--           { line = 1, column = 2, security = 3, message = 4 }
--         },
--         rootPatterns = {".git", "pylintrc", "setup.py"},
--         securities = {
--           informational = "hint",
--           refactor = "info",
--           convention = "info",
--           warning = "warning",
--           error = "error",
--           fatal = "error"
--         },
--         offsetColumn = 1,
--         formatLines = 1,
--         required_files = {"pylintrc"}
--       }
--     }
--   }
-- })

vim.g.diagnostic_enable_virtual_text = 1
vim.g.diagnostic_enable_underline = 0
vim.g.diagnostic_virtual_text_prefix = ' '

vim.fn.sign_define("LspDiagnosticsErrorSign"  , {text = "✘", texthl = "LspDiagnosticsErrorSign"})
vim.fn.sign_define("LspDiagnosticsWarningSign", {text = "!", texthl = "LspDiagnosticsWarningSign"})
