local nvim_lsp   = require'nvim_lsp'
local metals     = require'metals'
local completion = require'completion'
local diagnostic = require'diagnostic'
local M = {}

vim.lsp.set_log_level(0)

local keymap = function(mode, key, result)
  vim.api.nvim_buf_set_keymap(0, mode, key, result, {noremap = true, silent = true})
end

local custom_on_attach = function(client)
  diagnostic.on_attach(client)
  completion.on_attach(client)

  keymap('n', '<C-]>'     , '<cmd>lua vim.lsp.buf.definition()<CR>')
  keymap('n', 'K'         , '<cmd>lua vim.lsp.buf.hover()<CR>')
  keymap('n', 'gK'        , '<cmd>lua vim.lsp.buf.signature_help()<CR>')
  keymap('n', 'gr'        , '<cmd>lua vim.lsp.buf.references()<CR>')
  keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')
  keymap('n', ']d'        , '<cmd>lua vim.lsp.structures.Diagnostic.buf_move_next_diagnostic()<CR>')
  keymap('n', '[d'        , '<cmd>lua vim.lsp.structures.Diagnostic.buf_move_prev_diagnostic()<CR>')
  keymap('n', 'go'        , ':OpenDiagnostic<CR>')

  vim.bo.omnifunc = 'v:lua.vim.lsp.omnifunc'
end

local executable = function(x)
  return vim.fn.executable(x) ~= 0
end

if executable('vim-language-server') then
  nvim_lsp.vimls.setup  { on_attach = custom_on_attach }
end

-- if executable('bash-language-server') then
--   nvim_lsp.bashls.setup { on_attach = custom_on_attach }
-- end
-- LspInstall bashls
nvim_lsp.bashls.setup { on_attach = custom_on_attach }

-- nvim_lsp.jedi_language_server.setup{ on_attach = custom_on_attach; }
-- nvim_lsp.pyls.setup   {
--   on_attach = custom_on_attach,
--   settings = {
--     pyls = {
--       plugins = {
--         pycodestyle = { enabled = false },
--         -- pylint = { enabled = false },
--         rope = { enabled = false },
--         mccabe = { enabled = false },
--       }
--     }
--   },
-- }
-- nvim_lsp.diagnosticls.setup {
--   on_attach = diagnostic.on_attach,
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
-- }

-- require('nlua.lsp.nvim').setup(nvim_lsp, { on_attach = custom_on_attach })

nvim_lsp.metals.setup{
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
}

local configs = require 'nvim_lsp/configs'


if executable('lua-lsp') then
  configs.lua_lsp2 = {
    default_config = {
      cmd = {"lua-lsp"},
      filetypes = {"lua"},
      root_dir = function(fname)
        return vim.fn.getcwd()
      end
    }
  }
  configs.lua_lsp2.setup { on_attach = custom_on_attach }
end
