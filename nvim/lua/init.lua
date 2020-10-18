local filename = function()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("^.*/(.*)$") or str
end

function loadrequire(module)
    local stat, res = pcall(require, module)
    if not stat then
      print(filename()..': Module '..vim.inspect(module)..' is not available')
    end
    return res
end

loadrequire('lsp')
loadrequire('treesitter')
loadrequire('telescope_config')

loadrequire('gitsigns').setup()
