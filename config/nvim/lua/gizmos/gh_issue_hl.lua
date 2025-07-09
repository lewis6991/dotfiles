local api = vim.api

--- @type table<string, table<string, string>>
local cache = {}

---@param bufnr integer
---@param row integer
---@param callback fun(scol?: integer, ecol?: integer, state?: string)
local function get_state(bufnr, row, callback)
  local tick = vim.b.changedtick
  local line = api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
  local scol, ecol, repo, num = line:find('([%w-]+/[%w%.-_]+)#(%d+)')
  if not repo then
    return callback()
  end

  cache[repo] = cache[repo] or {}

  if cache[repo][num] then
    return callback(scol, ecol, cache[repo][num])
  end

  local handle = vim.system(
    { 'gh', 'issue', 'view', '--json', 'state', num, '--repo', repo },
    {},
    function(out)
      if vim.b[bufnr].changedtick ~= tick then
        return callback()
      end

      if out.code > 0 then
        return callback(scol, ecol, 'ERROR')
      end
      local json = vim.json.decode(out.stdout)
      cache[repo][num] = json.state --[[@as string]]
      callback(scol, ecol, json.state)
    end
  )

  api.nvim_create_autocmd('TextChanged', {
    buffer = bufnr,
    once = true,
    callback = function()
      handle:kill(9)
      return callback()
    end,
  })
end

local ns = api.nvim_create_namespace('ghhl')

--- @type table<integer, table<integer, boolean>>
local in_progress = {}

local question_hl = api.nvim_get_hl(0, { name = 'Special' })
api.nvim_set_hl(0, 'GhIssueOpen', { fg = question_hl.fg })
api.nvim_set_hl(0, 'GhIssueClosed', { fg = question_hl.fg, strikethrough = true })

api.nvim_set_decoration_provider(ns, {
  on_line = function(_, _winid, bufnr, row)
    in_progress[bufnr] = in_progress[bufnr] or {}
    if in_progress[bufnr][row] then
      return
    end
    in_progress[bufnr][row] = true
    get_state(
      bufnr,
      row,
      vim.schedule_wrap(function(scol, ecol, state)
        in_progress[bufnr][row] = nil
        if api.nvim_buf_is_valid(bufnr) == false then
          return
        end
        api.nvim_buf_clear_namespace(bufnr, ns, row, row + 1)

        if not state then
          return
        end

        local hl_group = state == 'OPEN' and 'GhIssueOpen'
          or state == 'CLOSED' and 'GhIssueClosed'
          or 'Error'

        pcall(api.nvim_buf_set_extmark, bufnr, ns, row, scol - 1, {
          hl_group = hl_group,
          end_col = ecol,
        })
      end)
    )
  end,
})
