local nvim_lsp = require 'lspconfig'
local metals   = require 'metals'

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

local function is_installed(config)
  if config.install_info then
    local info = config.install_info()
    if info.is_installed then
      return true
    elseif info.binaries then
      for k, _ in pairs(info.binaries) do
        if vim.fn.executable(k) == 0 then
          return false
        end
      end
      return true
    end
  else
    local cmd = config.document_config.default_config.cmd[1]
    return vim.fn.executable(cmd) == 0
  end
  return false
end

local function setup(config, opts)
  if not is_installed(config) then
    -- print(('%s is not installed'):format(config.name))
    return
  end

  opts = opts or {}

  if not opts.on_attach then
    opts.on_attach = custom_on_attach
  end

  config.setup(opts)
end

-- npm install -g vim-language-server
-- LspInstall vimls
setup(nvim_lsp.vimls)

-- LspInstall bashls
setup(nvim_lsp.bashls)

-- pip3 install jedi-language-server
setup(nvim_lsp.jedi_language_server)

-- LspInstall sumneko_lua
-- setup(nvim_lsp.sumneko_lua)

if is_installed(nvim_lsp.sumneko_lua) then
  require('nlua.lsp.nvim').setup(nvim_lsp, { on_attach = custom_on_attach })
end

setup(nvim_lsp.diagnosticls, {
  root_dir = nvim_lsp.util.root_pattern("pylintrc", "setup.cfg", ".git"),
  filetypes = {"python"},
  init_options = {
    filetypes = {
      python = "pylint"
    },
    linters = {
      pylint = {
        sourceName = "pylint",
        command = "pylint",
        args = {
          "--output-format", "text",
          "--score"        , "no",
          "--msg-template" , "'{line}:{column}:{category}:{msg} ({msg_id}:{symbol})'",
          "%file"
        },
        formatPattern = {
          "^(\\d+?):(\\d+?):([a-z]+?):(.*)$",
          { line = 1, column = 2, security = 3, message = 4 }
        },
        rootPatterns = {".git", "pylintrc", "setup.py"},
        securities = {
          informational = "hint",
          refactor = "info",
          convention = "info",
          warning = "warning",
          error = "error",
          fatal = "error"
        },
        offsetColumn = 1,
        formatLines = 1,
        required_files = {"pylintrc"}
      }
    }
  }
})

setup(nvim_lsp.metals, {
  on_attach = function()
    custom_on_attach();
    require'metals.setup'.auto_commands()
  end;
  root_dir     = metals.root_pattern("build.sbt", "build.sc", ".git");
  init_options = {
    -- If you set this, make sure to have the `metals#status()` function
    -- in your statusline, or you won't see any status messages
    statusBarProvider            = "on";
    inputBoxProvider             = true;
    quickPickProvider            = true;
    executeClientCommandProvider = true;
    decorationProvider           = true;
    didFocusProvider             = true;
  };

  callbacks = {
    ["textDocument/hover"]          = metals['textDocument/hover'];
    ["metals/status"]               = metals['metals/status'];
    ["metals/inputBox"]             = metals['metals/inputBox'];
    ["metals/quickPick"]            = metals['metals/quickPick'];
    ["metals/executeClientCommand"] = metals["metals/executeClientCommand"];
    ["metals/publishDecorations"]   = metals["metals/publishDecorations"];
    ["metals/didFocusTextDocument"] = metals["metals/didFocusTextDocument"];
  };
})

-- local configs = require 'lspconfig/configs'
-- configs.lua_lsp2 = {
--   default_config = {
--     cmd = {"lua-lsp"},
--     filetypes = {"lua"},
--     root_dir = function(fname)
--       return vim.fn.getcwd()
--     end
--   }
-- }
-- configs.lua_lsp2.setup { on_attach = custom_on_attach }

vim.g.diagnostic_enable_virtual_text = 1
vim.g.diagnostic_enable_underline = 0
vim.g.diagnostic_virtual_text_prefix = ' '

vim.fn.sign_define("LspDiagnosticsErrorSign"  , {text = "✘", texthl = "LspDiagnosticsErrorSign"})
vim.fn.sign_define("LspDiagnosticsWarningSign", {text = "!", texthl = "LspDiagnosticsWarningSign"})
