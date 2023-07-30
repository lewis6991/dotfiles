-- require("neodev").setup({
--   override = function(root_dir, library)
--     local obj = vim.system({'git', 'remote', 'get-url', 'origin'}, {cwd = root_dir}):wait()
--     if obj.stdout:match('lewis6991/neovim') then
--       library.enabled = false
--     end
--   end
-- })

--- @param path string
--- @param markers string[]
--- @return string?
local function find_root(path, markers)
  local match = vim.fs.find(markers, { path = path, upward = true })[1]
  if not match then
    return
  end
  local stat = vim.loop.fs_stat(match)
  local isdir = stat and stat.type == "directory"
  return vim.fn.fnamemodify(match, isdir and ':p:h:h' or ':p:h')
end

local lsp_group = vim.api.nvim_create_augroup('lewis6991.lsp', {})

local function setup_cmp(config)
  config.capabilities = vim.lsp.protocol.make_client_capabilities()
  vim.tbl_extend('force', config.capabilities, require('cmp_nvim_lsp').default_capabilities())
end

local function setup(config)
  vim.api.nvim_create_autocmd('FileType', {
    pattern = config.filetype,
    group = lsp_group,
    callback = vim.schedule_wrap(function(args)
      setup_cmp(config)

      config.capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

      config.markers = config.markers or {}
      table.insert(config.markers, '.git')
      config.root_dir = find_root(args.file, config.markers)

      vim.lsp.start(config)
    end),
  })
end

setup {
  filetype = 'c',
  cmd = { 'clangd' },
  markers = { 'compile_commands.json' },
}

setup {
  name = 'luals',
  filetype = 'lua',
  cmd = { 'lua-language-server' },
  markers = { '.luarc.json' },
  settings = {
    Lua = {
      workspace = {
        checkThirdParty = false
      },
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
      }
    }
  }
}

setup {
  name = 'pyright',
  cmd = { 'pyright-langserver', '--stdio' },
  filetype = 'python',
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = 'workspace',
      },
    },
  },
}

setup {
  name = 'bashls',
  cmd = { 'bash-language-server', 'start' },
  filetype = 'sh',
}

-- vim.api.nvim_create_autocmd('LspAttach', {
--   callback = function(args)
--     local bufnr = args.buf
--     local client = vim.lsp.get_client_by_id(args.data.client_id)
--     client.server_capabilities.semanticTokensProvider = nil
--   end
-- })
