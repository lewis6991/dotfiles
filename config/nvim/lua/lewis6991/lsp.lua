--- @param path string
--- @param markers string[]
--- @return string?
local function find_root(path, markers)
  local match = vim.fs.find(markers, { path = path, upward = true })[1]
  if not match then
    return
  end
  local stat = vim.uv.fs_stat(match)
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
    callback = function(args)
      local exe = config.cmd[1]
      if vim.fn.executable(exe) ~= 1 then
        vim.notify(string.format("Cannot start %s: '%s' not in PATH", config.name, exe), vim.log.levels.ERROR)
        return true
      end

      setup_cmp(config)

      config.capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

      config.markers = config.markers or {}
      table.insert(config.markers, '.git')
      config.root_dir = find_root(args.file, config.markers)

      -- buffer could have switched due to schedule_wrap so need to run buf_call
      vim.lsp.start(config, { bufnr = args.buf })
    end
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
  on_init = function(client)
    local path = client.workspace_folders[1].name
    if not vim.uv.fs_stat(path..'/.luarc.json') and not vim.uv.fs_stat(path..'/.luarc.jsonc') then
      local settings = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = {
          version = 'LuaJIT'
        },
        workspace = {
          library = { vim.env.VIMRUNTIME }
          -- library = vim.api.nvim_get_runtime_file("", true)
        }
      })

      client.notify("workspace/didChangeConfiguration", { settings = settings })
    end
    return true
  end,
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

--- npm i -g vscode-langservers-extracted
setup {
  name = 'jsonls',
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetype = { 'json', 'jsonc' },
  install = {'npm', 'i', '-g', 'vscode-langservers-extracted' }
}

-- vim.api.nvim_create_autocmd('LspAttach', {
--   callback = function(args)
--     local bufnr = args.buf
--     local client = vim.lsp.get_client_by_id(args.data.client_id)
--     client.server_capabilities.semanticTokensProvider = nil
--   end
-- })
