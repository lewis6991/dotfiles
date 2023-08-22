--- @param path string
--- @param markers string[]
--- @return string?
local function find_root(path, markers)
  path = vim.uv.fs_realpath(path)
  if not path then
    return
  end

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
      if vim.bo[args.buf].buftype == 'nofile' then
        return
      end

      local exe = config.cmd[1]
      if vim.fn.executable(exe) ~= 1 then
        vim.notify(string.format("Cannot start %s: '%s' not in PATH", config.name, exe), vim.log.levels.ERROR)
        return true
      end

      setup_cmp(config)

      -- config.capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

      config.markers = config.markers or {}
      table.insert(config.markers, '.git')
      config.root_dir = find_root(args.file, config.markers)
      if not config.root_dir then
        return
      end

      -- buffer could have switched due to schedule_wrap so need to run buf_call
      vim.lsp.start(config, { bufnr = args.buf })
    end
  })
end

-- Clangd
setup {
  filetype = 'c',
  cmd = { 'clangd' },
  markers = { 'compile_commands.json' },
}

local function add_settings(client, settings)
  local config = client.config
  config.settings = vim.tbl_deep_extend('force', config.settings, settings)
  client.notify("workspace/didChangeConfiguration", { settings = config.settings })
end

local function default_lua_settings()
  return {
    Lua = {
      runtime = {
        version = 'LuaJIT'
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          "${3rd}/busted/library",
          "${3rd}/luv/library"
        }
        -- library = vim.api.nvim_get_runtime_file("", true)
      }
    }
  }
end

-- LuaLS
setup {
  name = 'luals',
  filetype = 'lua',
  cmd = { 'lua-language-server' },
  markers = { '.luarc.json' },
  on_init = function(client)
    local path = client.workspace_folders[1].name
    if not vim.uv.fs_stat(path..'/.luarc.json') and not vim.uv.fs_stat(path..'/.luarc.jsonc') then
      add_settings(client, default_lua_settings())
    end
    return true
  end,
  settings = {
    Lua = {
      hint = {
        enable = true,
        paramName = 'Literal',
        setType = true
      }
    }
  }
}

-- Pyright
setup {
  name = 'pyright',
  cmd = { 'pyright-langserver', '--stdio' },
  filetype = 'python',
  markers = { 'pyproject.toml' },
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

-- Bash
setup {
  name = 'bashls',
  cmd = { 'bash-language-server', 'start' },
  filetype = 'sh',
}

-- Json
-- npm i -g vscode-langservers-extracted
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


do -- fswatch

  local FSWATCH_EVENTS = {
    Created = 1,
    Updated = 2,
    Removed = 3,
    -- Renamed
    OwnerModified = 2,
    AttributeModified = 2,
    MovedFrom = 1,
    MovedTo = 3,
    -- IsFile
    IsDir = false,
    IsSymLink = false,
    PlatformSpecific = false,
    -- Link
    -- Overflow
  }

  --- @param data string
  --- @param opts table
  --- @param callback fun(path: string, event: integer)
  local function fswatch_output_handler(data, opts, callback)
    local d = vim.split(data, '%s+')
    local cpath = d[1]

    for i = 2, #d do
      if FSWATCH_EVENTS[d[i]] == false then
        return
      end
    end

    if opts.include_pattern and opts.include_pattern:match(cpath) == nil then
      return
    end

    if opts.exclude_pattern and opts.exclude_pattern:match(cpath) ~= nil then
      return
    end

    for i = 2, #d do
      local e = FSWATCH_EVENTS[d[i]]
      if e then
        callback(cpath, e)
      end
    end
  end

  local function fswatch(path, opts, callback)
    local obj = vim.system({
      'fswatch',
      '--recursive',
      '--event-flags',
      '--exclude', '/.git/',
      path
    }, {
      stdout = function(err, data)
        if err then
          error(err)
        end

        if not data then
          return
        end

        for line in vim.gsplit(data, '\n', { plain = true, trimempty = true }) do
          fswatch_output_handler(line, opts, callback)
        end
      end
    })

    return function()
      obj:kill(2)
    end
  end

  if vim.fn.executable('fswatch') == 1 then
    require('vim.lsp._watchfiles')._watchfunc = fswatch
  end
end
