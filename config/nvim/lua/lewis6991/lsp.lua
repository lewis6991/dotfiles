local function setup(server, settings)
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  vim.tbl_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

  capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

  require'lspconfig'[server].setup{
    capabilities = capabilities,
    settings = settings
  }
end

require("neodev").setup({
  override = function(root_dir, library)
    local obj = vim.system({'git', 'remote', 'get-url', 'origin'}, {cwd = root_dir}):wait()
    if obj.stdout:match('lewis6991/neovim') then
      library.enabled = false
    end
  end
})

setup('clangd')
-- setup('cmake')

setup('lua_ls', {
  Lua = {
    hint = {
      enable = true,
      paramName = 'Literal',
      setType = true
    },

    diagnostics = {
      groupSeverity = {
        strong = 'Warning',
        strict = 'Warning',
      },
      groupFileStatus = {
        ["ambiguity"]  = "Opened",
        ["await"]      = "Opened",
        ["codestyle"]  = "None",
        ["duplicate"]  = "Opened",
        ["global"]     = "Opened",
        ["luadoc"]     = "Opened",
        ["redefined"]  = "Opened",
        ["strict"]     = "Opened",
        ["strong"]     = "Opened",
        ["type-check"] = "Opened",
        ["unbalanced"] = "Opened",
        ["unused"]     = "Opened",
      },
      unusedLocalExclude = { '_*' },
      globals = {
        'it',
        'describe',
        'before_each',
        'after_each',
        'pending'
      }
    },
  }
})

setup('pyright')
setup('bashls')
-- setup('teal_ls')
setup('rust_analyzer')

-- vim.api.nvim_create_autocmd('LspAttach', {
--   callback = function(args)
--     local bufnr = args.buf
--     local client = vim.lsp.get_client_by_id(args.data.client_id)
--     client.server_capabilities.semanticTokensProvider = nil
--   end
-- })
