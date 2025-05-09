local api = vim.api

local LANGS = {
  python = 'py',
}

local SHELLS = {
  sh = { '#! /usr/bin/env bash' },
  py = { '#! /usr/bin/env python3' },
  scala = { '#! /usr/bin/env scala' },
  tcl = { '#! /usr/bin/env tclsh' },
  lua = {
    '#! /bin/sh',
    '_=[[',
    'exec lua "$0" "$@"',
    ']]',
  },
}

api.nvim_create_user_command('Hashbang', function()
  ---@diagnostic disable-next-line: missing-parameter
  local extension = vim.fn.expand('%:e')

  if extension == '' then
    extension = LANGS[vim.bo.filetype] or vim.bo.filetype
  end

  if SHELLS[extension] then
    local hb = SHELLS[extension]
    hb[#hb + 1] = ''

    api.nvim_buf_set_lines(0, 0, 0, false, hb)
    api.nvim_create_autocmd('BufWritePost', {
      command = 'silent !chmod u+x %',
      buffer = 0,
      once = true,
    })
  end
end, { force = true })
