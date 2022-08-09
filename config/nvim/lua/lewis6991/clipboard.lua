local api, fn = vim.api, vim.fn

-- character table string
local N = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- encoding
local function enc(data)
  return ((data:gsub('.', function(x)
    local r, b = '', x:byte()
    for i = 8, 1, -1 do
      r = r .. (b % 2^i - b % 2^(i-1) > 0 and '1' or '0')
    end
    return r
  end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
      if #x < 6 then
        return ''
      end
      local c = 0
      for i = 1, 6 do
        c = c + (x:sub(i, i) == '1' and 2^(6 - i) or 0)
      end
      return N:sub(c + 1, c + 1)
    end)..({ '', '==', '=' })[#data%3+1])
end

api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    local text_b64 = enc(fn.getreg(vim.v.event.regname))
    local osc = string.format('%s]52;c;%s%s', string.char(0x1b), text_b64, string.char(0x07))

    if fn.chansend(vim.v.stderr, osc) <= 0 then
      api.nvim_echo({{'Failed to copy selection', 'ErrorMsg'}}, false, {})
    end
  end
})
