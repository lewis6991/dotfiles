local api, fn = vim.api, vim.fn

local luasnip = require 'luasnip'
local lspkind = require 'lspkind'

require 'lewis6991.cmp_gh'

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
    fields = { 'kind', 'abbr', 'menu' },
    format = function(entry, vim_item)
      vim_item.kind = lspkind.presets.default[vim_item.kind]

       -- set a name for each source
      vim_item.menu = ({
        buffer   = "Buf",
        nvim_lsp = "LSP",
        luasnip  = "LuaSnip",
        nvim_lua = "Lua",
        path     = 'Path',
        tmux     = 'Tmux',
        gh       = 'GH',
      })[entry.source.name]

      local maxwidth = 40
      if #vim_item.abbr > maxwidth then
        vim_item.abbr = vim_item.abbr:sub(1, maxwidth)..'...'
      end
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
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        fn.feedkeys(t'<Plug>luasnip-expand-or-jump', '')
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        fn.feedkeys(t'<Plug>luasnip-jump-prev', '')
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = 'gh' },
    { name = 'nvim_lsp' },
    { name = 'nvim_lua' },
    { name = 'luasnip'  },
    { name = 'path'     },
    { name = 'buffer'   },
    { name = 'tmux', keyword_length=3, max_item_count=10},
  },
  }

cmp.setup.cmdline('/', { sources = { { name = 'buffer'  } } })
cmp.setup.cmdline(':', { sources = { { name = 'cmdline' } } })

