--stylua: ignore
--- @alias lewis6991.intro.HlRange [integer, integer, integer, string]

if vim.fn.argc() > 0 then
  return
end

local api = vim.api

local INTRO_LOGO_BLUE = 0x3E93D3
local INTRO_LOGO_GREEN = 0x69A33E
local INTRO_WIDTH = 57

local version = vim.version()
local prerelease_suffix = ''
if version.prerelease then
  local prerelease = type(version.prerelease) == 'string' and version.prerelease or 'dev'
  prerelease_suffix = '-' .. prerelease
  if version.build then
    prerelease_suffix = prerelease_suffix .. '+' .. version.build
  end
end

local version_text = ('v%d.%d.%d%s  🚀'):format(
  version.major,
  version.minor,
  version.patch,
  prerelease_suffix
)
local version_line = 'NVIM ' .. version_text
local news_text = ('v%d.%d news'):format(version.major, version.minor)
local version_padding =
  string.rep(' ', math.floor(0.5 * math.max(0, INTRO_WIDTH - vim.fn.strdisplaywidth(version_line))))

local intro_lines = {
  '',
  '                       │ ╲ ││    ',
  '                       ││╲╲││    ',
  '                       ││ ╲ │    ',
  '',
  version_padding .. version_line,
  '', -- 2
  '     Nvim is open source and freely distributable  ✨    ', -- 3
  '                https://neovim.io/#chat  💬    ', -- 4
  '', -- 5
  '    type  :help nvim<Enter>       if you are new!  👋    ', -- 6
  '    type  :checkhealth<Enter>     to optimize Nvim 🩺    ', -- 7
  '    type  :q<Enter>               to exit         🚪     ', -- 8
  '    type  :help<Enter>            for help        📚     ', -- 9
  '', -- 10
  '    type  :help news<Enter>       ' .. news_text .. '    📰     ', -- 11
  '',
}

--- @param line_idx integer
--- @param text string
--- @param hl_group string
--- @return lewis6991.intro.HlRange
local function hl_match(line_idx, text, hl_group)
  local col_start = assert(intro_lines[line_idx]:find(text, 1, true)) - 1
  return { line_idx, col_start, col_start + #text, hl_group }
end

local ns_id = api.nvim_create_namespace('intro')

--- @param lines string[]
--- @param hl_ranges lewis6991.intro.HlRange[]
local function show_centered_float(lines, hl_ranges)
  -- Compute config data
  local width = 0
  for _, l in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(l))
  end

  -- Show
  local buf_id = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
  vim.bo[buf_id].bufhidden = 'wipe'

  local win_id = api.nvim_open_win(buf_id, false, {
    relative = 'editor',
    row = math.floor(0.5 * (vim.o.lines - #lines)),
    col = math.floor(0.5 * (vim.o.columns - width)),
    height = #lines,
    width = width,
    style = 'minimal',
    border = 'none',
  })

  -- Highlight
  api.nvim_set_hl(0, 'IntroBlue', { fg = INTRO_LOGO_BLUE })
  api.nvim_set_hl(0, 'IntroGreen', { fg = INTRO_LOGO_GREEN })
  for _, range in ipairs(hl_ranges) do
    api.nvim_buf_set_extmark(buf_id, ns_id, range[1] - 1, range[2], {
      end_row = range[1] - 1,
      end_col = range[3],
      hl_group = range[4],
    })
  end

  api.nvim_create_autocmd({ 'BufLeave', 'InsertEnter', 'CmdlineEnter', 'TextChanged' }, {
    group = api.nvim_create_augroup('intro_close_' .. win_id, { clear = true }),
    once = true,
    callback = function()
      if api.nvim_win_is_valid(win_id) then
        api.nvim_win_close(win_id, true)
      end
    end,
  })
end

--- @type lewis6991.intro.HlRange[]
local hl_ranges = {
  -- Art
  hl_match(2, '│', 'IntroBlue'),
  hl_match(2, '╲ ││', 'IntroGreen'),
  hl_match(3, '││', 'IntroBlue'),
  hl_match(3, '╲╲││', 'IntroGreen'),
  hl_match(4, '││', 'IntroBlue'),
  hl_match(4, '╲ │', 'IntroGreen'),

  -- Version
  hl_match(6, version_text, 'String'),

  -- Link
  hl_match(9, 'https://neovim.io/#chat', 'Underlined'),

  -- Commands
  hl_match(11, '<Enter>', 'SpecialKey'),
  hl_match(12, '<Enter>', 'SpecialKey'),
  hl_match(13, '<Enter>', 'SpecialKey'),
  hl_match(14, '<Enter>', 'SpecialKey'),
  hl_match(16, '<Enter>', 'SpecialKey'),

  hl_match(11, ':', 'SpecialKey'),
  hl_match(12, ':', 'SpecialKey'),
  hl_match(13, ':', 'SpecialKey'),
  hl_match(14, ':', 'SpecialKey'),
  hl_match(16, ':', 'SpecialKey'),

  hl_match(11, ':help nvim', 'Identifier'),
  hl_match(12, ':checkhealth', 'Identifier'),
  hl_match(13, ':q', 'Identifier'),
  hl_match(14, ':help', 'Identifier'),
  hl_match(16, ':help news', 'Identifier'),
}

show_centered_float(intro_lines, hl_ranges)
