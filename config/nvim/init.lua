local start = vim.uv.hrtime()

-- Random boolean
local enable_loader = vim.uv.random(1):byte(1) % 2 == 1

if enable_loader then
  vim.loader.enable()
end

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    local startuptime = (vim.uv.hrtime() - start) / 1e6

    local logpath = vim.fs.joinpath(vim.env.HOME, '.nvim_startuptime.log')

    local stats = {
      enabled = {
        avg = 0,
        high = 0,
        low = math.huge,
        cnt = 0,
      },
      disabled = {
        avg = 0,
        high = 0,
        low = math.huge,
        cnt = 0,
      },
    }

    local enabled_time = 0
    local disabled_time = 0

    if enable_loader then
      enabled_time = enabled_time + startuptime
    else
      disabled_time = disabled_time + startuptime
    end

    -- Read log
    if vim.uv.fs_stat(logpath) then
      for line in io.lines(logpath) do
        local state, time = line:match('%w+: Loader (.+), ([^ ]+)ms')
        time = tonumber(time) --[[@as integer]]
        if state == 'enabled' then
          stats.enabled.cnt = stats.enabled.cnt + 1
          stats.enabled.high = math.max(stats.enabled.high, time)
          stats.enabled.low = math.min(stats.enabled.low, time)
          enabled_time = enabled_time + time
        elseif state == 'disabled' then
          stats.disabled.cnt = stats.disabled.cnt + 1
          stats.disabled.high = math.max(stats.disabled.high, time)
          stats.disabled.low = math.min(stats.disabled.low, time)
          disabled_time = disabled_time + time
        else
          error('invalid: ' .. line)
        end
      end
      stats.enabled.avg = enabled_time / stats.enabled.cnt
      stats.disabled.avg = disabled_time / stats.disabled.cnt
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
