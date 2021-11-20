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
  playground = { enable = true }
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

function TS_get_tree(lnum)
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

vim.api.nvim_set_keymap('n', '<leader>Z', ':lua TS_get_tree()<cr>', {silent=true})

do -- Remove when neovim/pull/16348 is merged
  local function get_node_text(node, source)
    local start_row, start_col, start_byte = node:start()
    local end_row, end_col, end_byte = node:end_()

    if type(source) == "number" then
      local eof_row = vim.api.nvim_buf_line_count(source)
      if start_row >= eof_row then
        return nil
      end

      local end_offset = end_col == 0 and 0 or 1
      local lines = vim.api.nvim_buf_get_lines(source, start_row, end_row+end_offset, true)

      if end_col == 0 then
        end_col = -1
      end

      if #lines == 1 then
        lines[1]      = string.sub(lines[1], start_col+1, end_col)
      else
        lines[1]      = string.sub(lines[1], start_col+1)
        lines[#lines] = string.sub(lines[#lines], 1, end_col)
      end

      return table.concat(lines, '\n')
    elseif type(source) == "string" then
      return source:sub(start_byte+1, end_byte)
    end
  end

  local function override_predicate(name, handler)
    vim.treesitter.query.add_predicate(name, handler, true)
  end

  override_predicate("lua-match?", function(match, _, source, predicate)
    local node = match[predicate[2]]
    local regex = predicate[3]
    return string.find(get_node_text(node, source), regex)
  end)

  local magic_prefixes = {['\\v']=true, ['\\m']=true, ['\\M']=true, ['\\V']=true}

  local function check_magic(str)
    if string.len(str) < 2 or magic_prefixes[string.sub(str,1,2)] then
      return str
    end
    return '\\v'..str
  end

  local compiled_vim_regexes = setmetatable({}, {
    __index = function(t, pattern)
      local res = vim.regex(check_magic(pattern))
      rawset(t, pattern, res)
      return res
    end
  })

  override_predicate("match?", function(match, _, source, pred)
    local node = match[pred[2]]
    local regex = compiled_vim_regexes[pred[3]]
    return regex:match_str(get_node_text(node, source))
  end)

end
