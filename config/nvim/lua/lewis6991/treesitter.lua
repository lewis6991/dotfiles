require'nvim-treesitter'.define_modules {
  fold = {
    attach = function(_, _)
      vim.cmd'set foldmethod=expr foldexpr=nvim_treesitter#foldexpr()'
    end,
    detach = function() end,
  }
}

local langs = {
    "python",
    -- "json",
    "html",
    "bash",
    "lua",
    "rst",
    "teal",
  }

require'nvim-treesitter.configs'.setup {
  ensure_installed = langs,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
    is_supported = function(lang)
      return lang == 'lua'
    end
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
  fold = {
    enable = true,
    disable = {'rst', 'python'}
  },
  playground = { enable = true },
  context_commentstring = { enable = true }
}

-- Make sure legacy syntax engine is disable for TS langs
for _, l in ipairs(langs) do
  vim.cmd(('autocmd vimrc FileType %s syntax clear'):format(l))
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

-- parsers.list.lua.install_info.url = '/Users/lewis/projects/nvim-tree-sitter-lua'
-- parsers.list.lua.install_info.url = '/Users/lewis/.data/nvim/site/pack/packer/start/nvim-treesitter/grammar/lua'

local function ts_get_tree(lnum)
  lnum = lnum or vim.api.nvim_win_get_cursor(0)[1]

  local parsers = require'nvim-treesitter.parsers'
  local parser = parsers.get_parser()

  if not parser or not lnum then
    return -1
  end

  local node = get_node_at_line(parser:parse()[1]:root(), lnum-1)
  while node do
    print(vim.inspect(tostring(node)))
    node = node:parent()
  end
end

vim.api.nvim_set_keymap('n', '<leader>Z', '', {silent=true, callback=ts_get_tree})
