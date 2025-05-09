# `lint.lua`

Leaner version of https://github.com/mfussenegger/nvim-lint

### Usage

```lua

local did_setup = false

vim.api.nvim_create_autocmd({ 'InsertLeave', 'FileType', 'TextChanged', 'BufWrite' }, {
  callback = function()
    local lint = require('gizmos.lint')

    if not did_setup then
      lint.linters = {
        tcl = { tcl_lint },
        lua = { stylua_lint },
      }
      did_setup = true
    end

    lint.lint()
  end,
})
```

### Linter specification

```lua
--- @class gizmos.lint.Linter
--- @field name string
--- @field cmd (string|fun(bufnr: integer):string)[]
---
--- Send content via stdin. Defaults to false
--- @field stdin? boolean
---
--- Result stream. Defaults to stdout
--- @field stream? 'stdout'|'stderr'
---
--- If exit code != 1 should be ignored or result in a warning. Defaults to false
--- @field ignore_exitcode? boolean
---
--- Defaults to buffer directory if it exists
--- @field cwd? string
---
--- @field parser fun(bufnr: integer, output: string): vim.Diagnostic[]
---
--- @field ns? integer
```

### Example

```lua
local mylinter = {
  name = 'mylinter',
  cmd = { 'mylinter' },
  ignore_exitcode = true,
  parser = function(bufnr, output)
    local diags = {} --- @type vim.Diagnostic[]
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    for line in vim.gsplit(output, '\n') do
      local ok, _, path, lnum, sev, msg = line:find('^([^:]+): Line%s+(%d+): (.) (.+)$')
      if ok and vim.endswith(bufname, path) then
        diags[#diags + 1] = {
          lnum = tonumber(lnum - 1) --[[@as integer]],
          col = 0,
          message = msg,
          severity = sev,
        }
      end
    end

    return diags
  end,
}

require('gizmos.lint').linters = {
  myfiletype = { mylinter },
}

```
