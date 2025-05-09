local api = vim.api

api.nvim_set_hl(0, 'Gizmos.MarkSign', { link = 'ErrorMsg', default = true })
api.nvim_set_hl(0, 'Gizmos.MarkSignNum', { default = true })
api.nvim_set_hl(0, 'Gizmos.MarkSignPos', { default = true })

local ns = api.nvim_create_namespace('marksigns.nvim')

--- @param bufnr integer
--- @param mark vim.fn.getmarklist.ret.item
local function decor_mark(bufnr, mark)
  local row = mark.pos[2] - 1
  local col = mark.pos[3] - 1
  local off = mark.pos[4]

  api.nvim_buf_set_extmark(bufnr, ns, row, 0, {
    sign_text = "'" .. mark.mark:sub(2),
    sign_hl_group = 'Gizmos.MarkSign',
    number_hl_group = 'Gizmos.MarkSignNum',
  })
  -- Pcall in case the line length is zero
  pcall(api.nvim_buf_set_extmark, bufnr, ns, row, col, {
    end_col = col + off + 1,
    hl_group = 'Gizmos.MarkSignPos',
  })
end

api.nvim_set_decoration_provider(ns, {
  on_win = function(_, _, bufnr, toprow, botrow)
    api.nvim_buf_clear_namespace(bufnr, ns, toprow, botrow)

    local current_file = api.nvim_buf_get_name(bufnr)

    -- Global marks
    for _, mark in ipairs(vim.fn.getmarklist()) do
      if mark.mark:match('^.[a-zA-Z]$') then
        local mark_file = vim.fn.fnamemodify(mark.file, ':p:a')
        if current_file == mark_file then
          decor_mark(bufnr, mark)
        end
      end
    end

    -- Local marks
    for _, mark in ipairs(vim.fn.getmarklist(bufnr)) do
      if mark.mark:match('^.[a-zA-Z]$') then
        decor_mark(bufnr, mark)
      end
    end
  end,
})

-- Redraw screen when marks are changed via `m` commands
vim.on_key(function(_, typed)
  if typed:sub(1, 1) ~= 'm' then
    return
  end

  local mark = typed:sub(2)

  vim.schedule(function()
    if mark:match('[A-Z]') then
      for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
        api.nvim__redraw({ win = win, range = { 0, -1 } })
      end
    else
      api.nvim__redraw({ range = { 0, -1 } })
    end
  end)
end, ns)

-- https://github.com/kshenoy/vim-signature
-- https://github.com/chentoast/marks.nvim
