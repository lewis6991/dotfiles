require'plugins'

P = function(v)
  print(vim.inspect(v))
  return v
end

local opts_info = vim.api.nvim_get_all_options_info()

local opt = setmetatable({}, {
  __newindex = function(_, key, value)
    vim.o[key] = value
    local scope = opts_info[key].scope
    if scope == 'win' then
      vim.wo[key] = value
    elseif scope == 'buf' then
      vim.bo[key] = value
    end
  end
})

opt.inccommand = 'split'
opt.previewheight = 30

-- Remove tilda from signcolumn
opt.fillchars = 'eob: '

opt.signcolumn = 'auto:3'

opt.pumblend=10
opt.winblend=10

vim.cmd'hi SpellBad guisp=#663333'
