local dap = require('dap')

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

local function keymap(lhs, f, opts)
  vim.keymap.set('n', lhs, function()
    f()
  end, opts)
end

keymap('<leader>db', dap.toggle_breakpoint, { noremap = true })
keymap('<leader>dc', dap.continue, { noremap = true })
keymap('<leader>do', dap.step_over, { noremap = true })
keymap('<leader>di', dap.step_into, { noremap = true })

keymap('<leader>dl', function()
  require('osv').launch({ port = 8086 })
end, { noremap = true })

keymap('<leader>dw', function()
  require('dapui').open()
end)

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

local function make_luals_debug_config(args)
  local config = {
    name = 'Debug LuaLS test',
    type = 'lua-local',
    request = 'launch',
    program = {
      command = 'lua-language-server',
    },
    args = args,
    cwd = '${workspaceFolder}',
  }
  return config
end

vim.api.nvim_create_user_command('LaunchDebuggerLuaLs', function()
  require('dap').run(make_luals_debug_config({ 'test.lua' }))
end, {})
