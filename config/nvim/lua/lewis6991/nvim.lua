
local M = {}

function M.autocmd(name)
  return function(opts)
    if opts[1] then
      if type(opts[1]) == 'function' then
        opts.callback = opts[1]
      elseif type(opts[1]) == 'string' then
        opts.command = opts[1]
      end
      opts[1] = nil
    end
    vim.api.nvim_create_autocmd(name, opts)
  end
end

function M.map(mode)
  return function(first)
    return function(second)
      local opts
      if type(second) == 'table' then
        opts = second
        second = opts[1]
        opts[1] = nil
      end
      vim.keymap.set(mode, first, second, opts)
    end
  end
end

function M.nmap(first) return M.map 'n' (first) end
function M.vmap(first) return M.map 'v' (first) end
function M.cmap(first) return M.map 'c' (first) end

return M
