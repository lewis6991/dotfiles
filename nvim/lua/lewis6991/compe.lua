local api, fn = vim.api, vim.fn

require'compe'.setup {
  source = {
    path       = true;
    buffer     = true;
    nvim_lsp   = true;
    nvim_lua   = true;
    spell      = true;
    tmux       = true;
  }
}

local function t(str)
  return api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
  local col = fn.col('.') - 1
  if col == 0 or fn.getline('.'):sub(col, col):match('%s') then
    return true
  else
    return false
  end
end

-- Use (s-)tab to:
-- move to prev/next item in completion menuone
_G.tab_complete = function()
  return fn.pumvisible() == 1 and t'<C-n>'
    or     check_back_space()   and t'<Tab>'
    or     fn['compe#complete']()
end

local function keymap(m, k, e, opts)
  api.nvim_set_keymap(m, k, e, {expr = true, unpack(opts or {})})
end

keymap('i', '<Tab>'  , 'v:lua.tab_complete()'  )
keymap('i', '<S-Tab>', 'pumvisible() ? "\\<C-p>" : "\\<S-Tab>"')
keymap('i', '<cr>'   , "compe#confirm('<CR>')" , {silent = true, noremap = true})

-- Workaround for https://github.com/hrsh7th/nvim-compe/issues/329
keymap('i', '<C-y>', 'pumvisible() ? "\\<C-y>\\<C-y>" : "\\<C-y>"')
keymap('i', '<C-e>', 'pumvisible() ? "\\<C-y>\\<C-e>" : "\\<C-e>"')
