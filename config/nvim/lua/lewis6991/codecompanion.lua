local done_setup = false

local function try_setup()
  if done_setup then
    return
  end
  done_setup = true

  require('codecompanion').setup({
    strategies = {
      chat = {
        adapter = 'copilot',
      },
      inline = {
        adapter = 'copilot',
      },
    },
  })
end

vim.defer_fn(try_setup, vim.o.updatetime)

do -- fidget integration
  --- @type table<any, ProgressHandle>
  local handles = {}

  local group = vim.api.nvim_create_augroup('CodeCompanionFidgetHooks', {})

  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'codecompanion',
    callback = vim.schedule_wrap(function()
      vim.wo.number = false
      vim.wo.relativenumber = false
      vim.wo.showbreak = ''
    end),
  })

  vim.api.nvim_create_autocmd('User', {
    pattern = 'CodeCompanionRequestStarted',
    group = group,
    callback = function(request)
      --- @type CodeCompanion.HTTPAdapter|CodeCompanion.ACPAdapter
      local adapter = request.data.adapter

      -- print(vim.inspect(request.data))
      handles[request.data.id] = require('fidget.progress').handle.create({
        title = (' Requesting assistance (%s)'):format(request.data.interaction),
        message = 'In progress...',
        lsp_client = {
          name = ('%s (%s)'):format(adapter.formatted_name, adapter.model),
        },
      })
    end,
  })

  vim.api.nvim_create_autocmd('User', {
    pattern = 'CodeCompanionRequestFinished',
    group = group,
    callback = function(request)
      local id = request.data.id
      local handle = handles[id]
      handles[id] = nil
      if handle then
        handle.message = (
          request.data.status == 'success' and 'Completed'
          or request.data.status == 'error' and ' Error'
          or '󰜺 Cancelled'
        )
        handle:finish()
      end
    end,
  })
end

vim.keymap.set({ 'v', 'n' }, '<leader>ae', function()
  try_setup()

  vim.ui.input({ prompt = 'CodeCompanion' }, function(input)
    if #vim.trim(input or '') ~= 0 then
      local line1 = vim.fn.getpos("'<")[2]
      local line2 = vim.fn.getpos("'>")[3]
      return require('codecompanion').inline({
        line1 = line1,
        line2 = line2,
        range = line2 - line1 + 1,
        args = input,
      })
    end
  end)
end, { desc = 'Code Companion' })
