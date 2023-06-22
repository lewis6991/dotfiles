local api = vim.api
vim.g.loaded_matchparen = 1

local PAREN_CHARS = {
  ['('] = true,
  [')'] = false,
  ['{'] = true,
  ['}'] = false,
  ['['] = true,
  [']'] = false,
}

local ns = api.nvim_create_namespace('ts_matchparen')

local function get_char(row, col)
  return api.nvim_buf_get_text(0, row, col, row, col + 1, {})[1]
end

local function hl_col(row, col)
  api.nvim_buf_set_extmark(0, ns, row, col, {
    end_row = row,
    end_col = col + 1,
    hl_group = 'MatchParen'
  })
end

api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
  group = api.nvim_create_augroup('ts_matchparen', {}),
  callback = function()
    api.nvim_buf_clear_namespace(0, ns, 0, -1)

    if not pcall(vim.treesitter.get_parser) then
      return
    end

    local cursor = api.nvim_win_get_cursor(0)
    local row, col = cursor[1] - 1, cursor[2]
    local cursor_char = get_char(row, col)

    local match = PAREN_CHARS[cursor_char]

    if match == nil then
      return
    end

    local srow, scol, erow, ecol = vim.treesitter.get_node():range()

    local row2, col2 --- @type integer, integer
    if match then
      row2, col2 = erow, ecol -1
    else
      row2, col2 = srow, scol
    end

    hl_col(row, col)
    hl_col(row2, col2)
  end
})
