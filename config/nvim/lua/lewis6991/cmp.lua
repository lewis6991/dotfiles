local luasnip = require 'luasnip'

require 'lewis6991.cmp_gh'

local source_names = {
  buffer   = "Buf",
  nvim_lsp = "LSP",
  luasnip  = "Snip",
  nvim_lua = "Lua",
  path     = 'Path',
  tmux     = 'Tmux',
  gh       = 'GH',
  cmdline  = 'CMD',
}

local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  formatting = {
    fields = { 'kind', 'abbr', 'menu' },
    format = function(entry, vim_item)
      local lspkind = require 'lspkind'
      vim_item.kind = lspkind.presets.default[vim_item.kind]

       -- set a name for each source
      local nm = source_names[entry.source.name]
      if nm then
        vim_item.menu = nm
      else
        vim_item.menu = entry.source.name
      end

      local maxwidth = 50
      if #vim_item.abbr > maxwidth then
        vim_item.abbr = vim_item.abbr:sub(1, maxwidth)..'...'
      end
      return vim_item
    end
  },
  mapping = {
    ['<Tab>']     = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
    ['<S-Tab>']   = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
    ['<C-n>']     = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
    ['<C-p>']     = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
    ['<Down>']    = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
    ['<Up>']      = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
    ['<C-d>']     = cmp.mapping.scroll_docs(-4),
    ['<C-f>']     = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>']      = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = true },
  },
  sources = {
    { name = 'gh'         },
    { name = 'nvim_lsp'   },
    { name = 'nvim_lsp_signature_help'},
    { name = 'nvim_lua'   },
    { name = 'luasnip'    },
    { name = 'emoji'      },
    { name = 'path'       },
    { name = 'treesitter' },
    { name = 'buffer'     },
    { name = 'rg'         },
    { name = 'spell'      },
    { name = 'tmux'       },
  },
  experimental = {
    ghost_text = true,
  }
}

cmp.setup.cmdline('/', { sources = { { name = 'buffer'  } } })
cmp.setup.cmdline(':', { sources = { { name = 'cmdline' } } })
