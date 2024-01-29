local api = vim.api
vim.g.loaded_matchparen = 1
vim.api.nvim_clear_autocmds({ group = 'matchparen' })

local ns = api.nvim_create_namespace('ts_matchparen')

--- @param bufnr integer
--- @param row integer
--- @param col integer
--- @return {[1]: TSNode, [2]: Query}[]
local function get_hl_ctx(bufnr, row, col)
  local buf_highlighter = vim.treesitter.highlighter.active[bufnr]

  if not buf_highlighter then
    return {}
  end

  --- @type {[1]: TSNode, [2]: Query}[]
  local ret = {}

  buf_highlighter.tree:for_each_tree(function(tstree, tree)
    if not tstree or not vim.treesitter.is_in_node_range(tstree:root(), row, col) then
      return
    end

    local ok, query = pcall(function()
      return buf_highlighter:get_query(tree:lang()):query()
    end)

    if ok then
      ret[#ret+1] = { tstree:root(), query }
    end
  end)

  return ret
end

--- @param bufnr integer
--- @param ctx? {[1]: TSNode, [2]: Query}[]
--- @param row integer
--- @param col integer
--- @param pred fun(capture: string): boolean?
--- @return TSNode?, Query?
local function get_node_at_pos(bufnr, ctx, row, col, pred)
  ctx = ctx or get_hl_ctx(bufnr, row, col)

  for _, t in ipairs(ctx) do
    local root, query = t[1], t[2]
    for capture, node in query:iter_captures(root, bufnr, row, row + 1) do
      if vim.treesitter.is_in_node_range(node, row, col) then
        local c = query.captures[capture] -- name of the capture in the query
        if c and pred(c) then
          return node, query
        end
      end
    end
  end
end

--- @param bufnr integer
--- @param row integer
--- @param col integer
--- @param ctx? {[1]: TSNode, [2]: Query}[]
--- @return TSNode?, Query?
local function get_pairnode_at_pos(bufnr, row, col, ctx)
  return get_node_at_pos(bufnr, ctx, row, col, function(c)
    if c:match('^keyword%.?') or c:match('^punctuation%.bracket%.?') then
      return true
    end
  end)
end

local function matchit()
  api.nvim_buf_clear_namespace(0, ns, 0, -1)

  local bufnr = api.nvim_get_current_buf()
  local cursor = api.nvim_win_get_cursor(0)
  local crow, ccol = cursor[1] - 1, cursor[2]

  local w1node, w1query = get_pairnode_at_pos(bufnr, crow, ccol)
  if not w1node then
    return
  end

  local container_node = w1node:parent()

  -- Refine the context to just `container_node`
  local ctx = { { container_node, w1query } }

  local _, w1scol, _, w1ecol = w1node:range()

  local srow, scol, erow, ecol = assert(container_node):range()

  --- @type TSNode?
  local w2node
  if crow == srow and w1scol == scol then
    w2node = get_pairnode_at_pos(bufnr, erow, ecol - 1, ctx)
  elseif crow == erow and w1ecol == ecol then
    w2node = get_pairnode_at_pos(bufnr, srow, scol, ctx)
  else
    -- w1node is inside the container node. Assume the paired node is at the
    -- end
    w2node = get_pairnode_at_pos(bufnr, erow, ecol - 1, ctx)
  end

  if w2node and w1node ~= w2node then
    local w2row, w2scol, _, w2ecol = w2node:range()
    api.nvim_buf_set_extmark(0, ns, w2row, w2scol, {
      end_row = w2row,
      end_col = w2ecol,
      hl_group = 'MatchParen'
    })
  end
end

api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
  group = api.nvim_create_augroup('ts_matchparen', {}),
  callback = matchit
})
