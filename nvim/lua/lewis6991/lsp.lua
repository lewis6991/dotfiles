local nvim_lsp = require 'lspconfig'

local M = {}

require'lspinstall'.setup()

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

vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  virtual_text = true,
  signs = true,
  update_in_insert = true,
})

local function executable(path)
  return vim.fn.executable(path) == 1
end

local function setup(config, opts)
  if not config then
    return
  end

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

-- Make runtime files discoverable to the server
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

local function get_lua_runtime()
  local result = {}

  for _, path in pairs(vim.api.nvim_list_runtime_paths()) do
    local lua_path = path .. "/lua/"
    if vim.fn.isdirectory(lua_path) then
      result[lua_path] = true
    end
  end

  -- This loads the `lua` files from nvim into the runtime.
  result[vim.fn.expand("$VIMRUNTIME/lua")] = true
  result[vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true

  return result;
end

setup(nvim_lsp.lua, {
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
        path = runtime_path,
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
        library = get_lua_runtime(),
        maxPreload = 10000,
        preloadFileSize = 10000,
      },
    },
  },
})

-- npm install -g vim-language-server
setup(nvim_lsp.vimls)

-- npm install -g bash-language-server
setup(nvim_lsp.bashls)

-- pip3 install jedi-language-server
setup(nvim_lsp.jedi_language_server)

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

M.setup_metals = function()
  require("metals").initialize_or_attach {
    init_options = {
      statusBarProvider = 'on'
    },
    settings = {
      showImplicitArguments = true,
    },
    on_attach = custom_on_attach
  }
end

vim.cmd[[augroup metals_lsp]]
vim.cmd[[au!]]
vim.cmd[[au FileType scala,sbt lua require'lewis6991.lsp'.setup_metals()]]
vim.cmd[[augroup END]]

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

return M
