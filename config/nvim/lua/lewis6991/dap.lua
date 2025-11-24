local dap = require('dap')

do -- keymaps
  local function keymap(lhs, f)
    vim.keymap.set('n', lhs, function()
      f()
    end)
  end

  keymap('<leader>db', dap.toggle_breakpoint)
  keymap('<leader>dc', dap.continue)
  keymap('<leader>do', dap.step_over)
  keymap('<leader>di', dap.step_into)
  keymap('<leader>dd', dap.disconnect)
  keymap('<leader>dq', dap.close)

  keymap('<leader>dl', function()
    require('osv').launch({ port = 8086 })
  end)
end

do -- scala
  -- Debug settings if you're using nvim-dap
  dap.configurations.scala = {
    {
      type = 'scala',
      request = 'launch',
      name = 'RunOrTest',
      metals = {
        runType = 'runOrTestFile',
        --args = { "firstArg", "secondArg", "thirdArg" }, -- here just as an example
      },
    },
    {
      type = 'scala',
      request = 'launch',
      name = 'Test Target',
      metals = {
        runType = 'testTarget',
      },
    },
  }
end

do -- lua
  -- nlua
  dap.configurations.lua = {
    {
      type = 'nlua',
      request = 'attach',
      name = 'Attach to running Neovim instance',
    },
  }

  -- Quickstart:
  -- - Launch the server in the debuggee using <leader>dl
  -- - Open another Neovim instance with the source file
  -- - Place breakpoint with <leader>db
  -- - Connect using the DAP client with <leader>dc
  -- - Run your script/plugin in the debuggee

  dap.adapters.nlua = function(callback, config)
    callback({
      type = 'server',
      host = config.host or '127.0.0.1',
      port = config.port or 8086,
    })
  end

  -- Install local-lua-debugger-vscode, either via:
  -- - Your package manager
  -- - From source:
  --     git clone https://github.com/tomblind/local-lua-debugger-vscode
  --     cd local-lua-debugger-vscode
  --     npm install
  --     npm run build
  dap.adapters['local-lua'] = {
    type = 'executable',
    command = 'node',
    args = {
      '/absolute/path/to/local-lua-debugger-vscode/extension/debugAdapter.js',
    },
    enrich_config = function(config, on_config)
      if not config['extensionPath'] then
        config = vim.deepcopy(config)
        -- 💀 If this is missing or wrong you'll see
        -- "module 'lldebugger' not found" errors in the dap-repl when trying to launch a debug session
        config.extensionPath = '/absolute/path/to/local-lua-debugger-vscode/'
      end
      on_config(config)
    end,
  }
end

do -- python
  --- @return string
  local function get_python_exe_path()
    local venv_path = os.getenv('VIRTUAL_ENV')
    if venv_path then
      return vim.fs.joinpath(venv_path, 'bin', 'python3')
    end

    local cwd = assert(vim.uv.cwd())
    local venv_dir = vim.fs.root(cwd, '.venv')
    if venv_dir then
      local venv = vim.fs.joinpath(venv_dir, '.venv')
      local venv_bin = vim.fs.joinpath(venv, 'bin', 'python3')
      if vim.uv.fs_stat(venv_bin) then
        return venv_bin
      end
    end

    return 'python3'
  end

  --- @param config dap.Configuration
  --- @param on_config fun(config: dap.Configuration)
  local function enrich_config(config, on_config)
    if not config.pythonPath and not config.python then
      config.pythonPath = get_python_exe_path()
    end
    on_config(config)
  end

  local function setup_python()
    dap.adapters.python = function(cb, config)
      if config.request == 'attach' then
        --- @type dap.ServerAdapter
        local adapter = {
          type = 'server',
          port = assert(
            (config.connect or config).port,
            '`connect.port` is required for a python `attach` configuration'
          ),
          host = (config.connect or config).host or '127.0.0.1',
          enrich_config = enrich_config,
          options = {
            source_filetype = 'python',
          },
        }
        cb(adapter)
      else
        --- @type dap.ExecutableAdapter
        local adapter = {
          type = 'executable',
          command = get_python_exe_path(),
          args = { '-m', 'debugpy.adapter' },
          enrich_config = enrich_config,
          options = {
            source_filetype = 'python',
          },
        }
        cb(adapter)
      end
    end

    -- nvim-dap logs warnings for unhandled custom events
    -- Mute it
    dap.listeners.before['event_debugpySockets']['dap-python'] = function() end
  end

  setup_python()

  --- @type dap.Configuration[]
  dap.configurations.python = {
    {
      type = 'python',
      request = 'launch',
      name = 'file',
      module = 'unittest',
      args = { '--verbose', '${file}' },
      justMyCode = false,
      console = 'integratedTerminal',
    },
    {
      type = 'python',
      request = 'launch',
      name = 'unittest',
      module = 'unittest',
      justMyCode = false,
    },
    {
      type = 'python',
      request = 'attach',
      name = 'attach',
      connect = { host = '127.0.0.1', port = 5678 },
      justMyCode = false,
    },
  }
end
