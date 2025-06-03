local function setup()
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

local handles = {}

local group = vim.api.nvim_create_augroup('CodeCompanionFidgetHooks', {})

vim.api.nvim_create_autocmd('User', {
  pattern = 'CodeCompanionRequestStarted',
  group = group,
  callback = function(request)
    local adapter = request.data.adapter

    handles[request.data.id] = require('fidget.progress').handle.create({
      title = (' Requesting assistance (%s)'):format(request.data.strategy),
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
    if not handle then
      if request.data.status == 'success' then
        handle.message = 'Completed'
      elseif request.data.status == 'error' then
        handle.message = ' Error'
      else
        handle.message = '󰜺 Cancelled'
      end
      handle:finish()
    end
  end,
})

local done_setup = false
vim.keymap.set({ 'v', 'n' }, '<leader>ae', function()
  if not done_setup then
    setup()
    done_setup = true
  end

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
