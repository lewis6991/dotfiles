-- Remove trailing backslash when joining lines
vim.keymap.set('n', 'J', function()
  local line = vim.fn.getline('.')
  if vim.endswith(line, [[\]]) then
    return '$xJ'
  else
    return 'J'
  end
end, { expr = true })
