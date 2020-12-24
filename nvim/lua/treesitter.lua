local langs = {
  "python",
  "json",
  "html",
  "bash",
  "lua",
  "rst",
  "verilog"
}

require'nvim-treesitter.configs'.setup {
  ensure_installed = langs,
  highlight = {
    enable = true,
    use_languagetree = true,
  },
  indent = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection    = "gnn",
      node_incremental  = "grn",
      scope_incremental = "grc",
      node_decremental  = "grm",
    },
  },
  playground = {
    enable = true,
    disable = {}
  }
  -- context = {
  --   disable = { "python" },
  -- }
}

table.insert(langs, 'systemverilog')
table.insert(langs, 'sh')

for _, l in pairs(langs) do
  vim.cmd(
    'autocmd vimrc FileType '..l..
    ' set'..
    ' foldmethod=expr'..
    ' nospell'..
    ' foldexpr=nvim_treesitter#foldexpr()'
  )
end

local function get_node_at_line(root, lnum)
  for node in root:iter_children() do
    local srow, _, erow = node:range()
    if srow == lnum then
      return node
    end

    if node:child_count() > 0 and srow < lnum and lnum <= erow then
      return get_node_at_line(node, lnum)
    end
  end

  local wrapper = root:descendant_for_range(lnum, 0, lnum, -1)
  local child = wrapper:child(0)
  return child or wrapper
end

local parsers = require'nvim-treesitter.parsers'

-- parsers.list.lua.install_info.url = '/Users/lewis/projects/nvim-tree-sitter-lua'
-- parsers.list.lua.install_info.url = '/Users/lewis/.data/nvim/site/pack/packer/start/nvim-treesitter/grammar/lua'

function get_tree(lnum)
  if not lnum then
    lnum = tonumber(vim.api.nvim_win_get_cursor(0)[1])
  end
  print(lnum)
  local parser = parsers.get_parser()
  if not parser or not lnum then return -1 end

  local node = get_node_at_line(parser:parse()[1]:root(), lnum-1)
  while node do
    print(vim.inspect(tostring(node)))
    node = node:parent()
  end
end
