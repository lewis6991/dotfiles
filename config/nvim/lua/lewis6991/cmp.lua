local source_names = {
  buffer = { 'Buf', 'String' },
  nvim_lsp = { 'LSP', 'Question' },
  nvim_lua = { 'Lua', 'ErrorMsg' },
  path = { 'Path', 'WarningMsg' },
  tmux = { 'Tmux', 'CursorLineNr' },
  gh = { 'GH', 'CmpItemMenu' },
  rg = { 'RG', 'CmpItemMenu' },
  cmdline = { 'CMD', 'CmpItemMenu' },
  spell = { 'Spell', 'CmpItemMenu' },
  copilot = { 'Copilot', 'MoreMsg' },
}

local symbols = {
  Text = '󰉿',
  Method = '󰆧',
  Function = '󰊕',
  Constructor = '',
  Field = '󰜢',
  Variable = '󰀫',
  Class = '󰠱',
  Interface = '',
  Module = '',
  Property = '󰜢',
  Unit = '󰑭',
  Value = '󰎠',
  Enum = '',
  Keyword = '󰌋',
  Snippet = ' Snip',
  Color = '󰏘',
  File = '󰈙',
  Reference = '󰈇',
  Folder = '󰉋',
  EnumMember = '',
  Constant = '󰏿',
  Struct = '󰙅',
  Event = '',
  Operator = '󰆕',
  TypeParameter = '',
  Copilot = '',
}

local function min_length(min)
  return function(entry, _)
    return entry:get_word():len() > min
  end
end

local function setup()
  local cmp = require('cmp')
  cmp.setup({
     expand = function(args)
       vim.snippet.expand(args.body)
     end,
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
          vim_item.abbr = vim_item.abbr:sub(1, maxwidth) .. '...'
        end
        return vim_item
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ['<Tab>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
      ['<S-Tab>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
      { name = 'copilot' },
      { name = 'nvim_lsp' },
      { name = 'path' },
      { name = 'buffer' },
    }, {
      { name = 'gh' },
      { name = 'emoji' },
      { name = 'spell' },
      { name = 'tmux', entry_filter = min_length(2) },
    }),
    experimental = {
      ghost_text = true,
    },
    sorting = {
      priority_weight = 2,
      comparators = {
        require("copilot_cmp.comparators").prioritize,

        -- Below is the default comparitor list and order for nvim-cmp
        cmp.config.compare.offset,
        -- cmp.config.compare.scopes, --this is commented in nvim-cmp too
        cmp.config.compare.exact,
        cmp.config.compare.score,
        cmp.config.compare.recently_used,
        cmp.config.compare.locality,
        cmp.config.compare.kind,
        cmp.config.compare.sort_text,
        cmp.config.compare.length,
        cmp.config.compare.order,
      },
    },
  })

  cmp.setup.cmdline('/', {
    sources = { { name = 'buffer' } },
    mapping = cmp.mapping.preset.cmdline(),
  })

  cmp.setup.cmdline(':', {
    sources = { { name = 'cmdline' } },
    mapping = cmp.mapping.preset.cmdline(),
  })
end

vim.api.nvim_create_autocmd({'InsertEnter', 'CmdLineEnter'}, {
  once = true,
  callback = setup
})
