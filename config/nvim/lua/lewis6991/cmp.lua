-- require 'lewis6991.cmp_gh'

local source_names = {
  buffer     = {'Buf'  , 'String'},
  nvim_lsp   = {''  , 'Question'},
  luasnip    = {'Snip' , 'CmpItemMenu'},
  -- nvim_lua   = {'Lua'  , 'ErrorMsg'},
  -- nvim_lua   = {'  '  , 'ErrorMsg'},
  nvim_lua   = {'Lua'  , 'ErrorMsg'},
  path       = {'Path' , 'WarningMsg'},
  tmux       = {'Tmux' , 'CursorLineNr'},
  gh         = {'GH'   , 'CmpItemMenu'},
  rg         = {'RG'   , 'CmpItemMenu'},
  cmdline    = {'CMD'  , 'CmpItemMenu'},
  spell      = {'Spell', 'CmpItemMenu'},
}

local symbols = {
  Text = '',
  Method = '',
  Function = '',
  Constructor = '',
  Field = 'ﰠ',
  Variable = '',
  Class = 'ﴯ',
  Interface = '',
  Module = '',
  Property = 'ﰠ',
  Unit = '塞',
  Value = '',
  Enum = '',
  Keyword = '',
  Snippet = ' Snip',
  Color = '',
  File = '',
  Reference = '',
  Folder = '',
  EnumMember = '',
  Constant = '',
  Struct = 'פּ',
  Event = '',
  Operator = '',
  TypeParameter = '',
  Namespace = '',
  Package = '',
  String = '',
  Number = '',
  Boolean = '',
  Array = '',
  Object = '',
  Key = '',
  Null = 'ﳠ',
}

local function min_length(min)
  return function(entry, _)
    return entry:get_word():len() > min
  end
end

local did_snippy = false

local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      if not did_snippy then
        require('snippy').setup({
          mappings = {
            is = {
              ['<Tab>'] = 'expand_or_advance',
              ['<S-Tab>'] = 'previous',
            },
            nx = {
              ['<leader>x'] = 'cut_text',
            },
          },
        })
        did_snippy = true
      end
      require('snippy').expand_snippet(args.body) -- For `snippy` users.
    end,
  },
  formatting = {
    fields = { 'kind', 'abbr', 'menu' },
    format = function(entry, vim_item)
      vim_item.kind = symbols[vim_item.kind]

       -- set a name for each source
      local nm = source_names[entry.source.name]
      if nm then
        vim_item.menu = nm[1]
        vim_item.menu_hl_group = 'NonText'
        vim_item.kind_hl_group = nm[2]
      else
        vim_item.menu = entry.source.name
      end

      local maxwidth = 60
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
  sources = cmp.config.sources({
    { name = 'nvim_lsp'   },
    { name = 'path'       },
    { name = 'buffer'     },
  }, {
    { name = 'gh'         },
    { name = 'emoji'      },
    { name = 'spell'      },
    { name = 'tmux', entry_filter = min_length(2) },
  }),
  experimental = {
    ghost_text = true,
  }
}

cmp.setup.cmdline('/', {
  sources = { { name = 'buffer' } },
  mapping = cmp.mapping.preset.cmdline()
})

cmp.setup.cmdline(':', {
  sources = { { name = 'cmdline' } },
  mapping = cmp.mapping.preset.cmdline()
})
