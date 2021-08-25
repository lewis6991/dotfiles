local api, fn = vim.api, vim.fn

local luasnip = require 'luasnip'
local lspkind = require 'lspkind'

local function t(str)
  return api.nvim_replace_termcodes(str, true, true, true)
end

local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  formatting = {
    format = function(_, vim_item)
      vim_item.kind = lspkind.presets.default[vim_item.kind]
      return vim_item
    end
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = function(fallback)
      if fn.pumvisible() == 1 then
        fn.feedkeys(t'<C-n>', 'n')
      elseif luasnip.expand_or_jumpable() then
        fn.feedkeys(t'<Plug>luasnip-expand-or-jump', '')
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if fn.pumvisible() == 1 then
        fn.feedkeys(t'<C-p>', 'n')
      elseif luasnip.jumpable(-1) then
        fn.feedkeys(t'<Plug>luasnip-jump-prev', '')
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'nvim_lua' },
    { name = 'buffer'   },
    { name = 'luasnip'  },
  },
}


-- local check_back_space = function()
--   local col = fn.col('.') - 1
--   if col == 0 or fn.getline('.'):sub(col, col):match('%s') then
--     return true
--   else
--     return false
--   end
-- end

-- -- Use (s-)tab to:
-- -- move to prev/next item in completion menuone
-- _G.tab_complete = function()
--   return fn.pumvisible() == 1 and t'<C-n>'
--     or     check_back_space()   and t'<Tab>'
--     or     fn['compe#complete']()
-- end

-- local function keymap(m, k, e, opts)
--   api.nvim_set_keymap(m, k, e, {expr = true, unpack(opts or {})})
-- end

-- -- Workaround for https://github.com/hrsh7th/nvim-compe/issues/329
-- keymap('i', '<C-y>', 'pumvisible() ? "\\<C-y>\\<C-y>" : "\\<C-y>"')
-- keymap('i', '<C-e>', 'pumvisible() ? "\\<C-y>\\<C-e>" : "\\<C-e>"')
