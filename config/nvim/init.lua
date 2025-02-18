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

    local enabled_avg = 0
    local disabled_avg = 0

    local enabled_time = enable_loader and startuptime or 0
    local enabled_count = enable_loader and 1 or 0
    local disabled_time = enable_loader and 0 or startuptime
    local disabled_count = enable_loader and 0 or 1

    do -- Read log
      if vim.uv.fs_stat(logpath) then
        for line in io.lines(logpath) do
          local state, time = line:match('%w+: Loader (.+), ([^ ]+)ms')
          if state == 'enabled' then
            enabled_count = enabled_count + 1
            enabled_time = enabled_time + tonumber(time)
          elseif state == 'disabled' then
            disabled_count = disabled_count + 1
            disabled_time = disabled_time + tonumber(time)
          else
            error('invalid: ' .. line)
          end
        end
        enabled_avg = enabled_time / enabled_count
        disabled_avg = disabled_time / disabled_count
      end
    end

    -- update log
    assert(io.open(logpath, 'a+')):write(('%s: %s, %sms, avg: %sms, cnt: %d\n'):format(
      os.date(),
      enable_loader and 'Loader enabled' or 'Loader disabled',
      startuptime,
      enable_loader and enabled_avg or disabled_avg,
      enable_loader and enabled_count or disabled_count
    ))

    print(('Loader time {enabled: %.0fms, disabled: %.0fms}'):format(enabled_avg, disabled_avg))
  end
})

-- Do all init in lewis6991/init.lua so it can be cached
require('lewis6991')
