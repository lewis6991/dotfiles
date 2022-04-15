require 'lewis6991.cmp_gh'

local source_names = {
  buffer     = {'BUF'  , 'String'},
  nvim_lsp   = {nil    , 'Question'},
  luasnip    = {'Snip' , 'CmpItemMenu'},
  -- nvim_lua   = {'Lua'  , 'ErrorMsg'},
  -- nvim_lua   = {'  '  , 'ErrorMsg'},
  nvim_lua   = {nil    , 'ErrorMsg'},
  path       = {'Path' , 'WarningMsg'},
  -- tmux       = {'Tmux' , 'CursorLineNr'},
  tmux       = {nil    , 'CursorLineNr'},
  gh         = {'GH'   , 'CmpItemMenu'},
  rg         = {'RG'   , 'CmpItemMenu'},
  cmdline    = {'CMD'  , 'CmpItemMenu'},
  spell      = {'Spell', 'CmpItemMenu'},
  -- treesitter = {'TS'   , 'Delimiter'}
  treesitter = {''    , 'Delimiter'}
}

local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      require'luasnip'.lsp_expand(args.body)
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
        vim_item.menu = nm[1]
        vim_item.menu_hl_group = nm[2]
        vim_item.kind_hl_group = nm[2]
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
  mapping = cmp.mapping.preset.insert{
    ['<Tab>']   = cmp.mapping.select_next_item{ behavior = cmp.SelectBehavior.Insert },
    ['<S-Tab>'] = cmp.mapping.select_prev_item{ behavior = cmp.SelectBehavior.Insert },
    ['<CR>']    = cmp.mapping.confirm { select = true },
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

cmp.setup.cmdline('/', {
  sources = {
    { name = 'treesitter' },
    { name = 'buffer' }
  },
  mapping = cmp.mapping.preset.cmdline()
})

cmp.setup.cmdline(':', {
  sources = {
    { name = 'cmdline' }
  },
  mapping = cmp.mapping.preset.cmdline()
})
