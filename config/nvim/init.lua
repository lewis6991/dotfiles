local start = vim.uv.hrtime()

-- Random boolean
local enable_loader = assert(vim.uv.random(1)):byte(1) % 2 == 1

if enable_loader then
  vim.loader.enable()
end

--- @param t number[]
--- @return number?
local function median(t)
  table.sort(t)
  local n = #t
  if n == 0 then
    return
  end
  if n % 2 == 1 then
    return t[math.ceil(n / 2)]
  else
    return (t[n / 2] + t[n / 2 + 1]) / 2
  end
end

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    local startuptime = (vim.uv.hrtime() - start) / 1e6

    local logpath = vim.fs.joinpath(vim.env.HOME, '.nvim_startuptime.log')

    local stats = {
      enabled = {
        avg = 0.0,
        high = 0.0,
        low = math.huge,
        cnt = 0,
      },
      disabled = {
        avg = 0.0,
        high = 0.0,
        low = math.huge,
        cnt = 0,
      },
    }

    local enabled_time = 0.0
    local disabled_time = 0.0

    if enable_loader then
      enabled_time = enabled_time + startuptime
    else
      disabled_time = disabled_time + startuptime
    end

    -- Read log
    if vim.uv.fs_stat(logpath) then
      local enabled_times = {} --- @type number[]
      local disabled_times = {} --- @type number[]
      for line in io.lines(logpath) do
        --- @type string, string
        local state, time_str = line:match('%w+: Loader (.+), ([^ ]+)ms')
        local time = tonumber(time_str) --[[@as number]]
        if state == 'enabled' then
          stats.enabled.cnt = stats.enabled.cnt + 1
          stats.enabled.high = math.max(stats.enabled.high, time)
          stats.enabled.low = math.min(stats.enabled.low, time)
          enabled_time = enabled_time + time
          enabled_times[#enabled_times + 1] = time
        elseif state == 'disabled' then
          stats.disabled.cnt = stats.disabled.cnt + 1
          stats.disabled.high = math.max(stats.disabled.high, time)
          stats.disabled.low = math.min(stats.disabled.low, time)
          disabled_time = disabled_time + time
          disabled_times[#disabled_times + 1] = time
        else
          error('invalid: ' .. line)
        end
      end
      stats.enabled.avg = enabled_time / stats.enabled.cnt
      stats.disabled.avg = disabled_time / stats.disabled.cnt

      stats.enabled.median = median(enabled_times)
      stats.disabled.median = median(disabled_times)
    end

    -- update log
    assert(io.open(logpath, 'a+')):write(
      ('%s: %s, %sms, avg: %sms\n'):format(
        os.date(),
        enable_loader and 'Loader enabled' or 'Loader disabled',
        startuptime,
        enable_loader and stats.enabled.avg or stats.disabled.avg
      )
    )

    vim.g.loader_stats = stats
  end,
})

-- Do all init in lewis6991/init.lua so it can be cached
require('lewis6991')
