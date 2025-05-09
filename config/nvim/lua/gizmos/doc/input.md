# `input.lua`

Very usable but basic implementation of `vim.ui.input()`.

Stripped down version of https://github.com/stevearc/dressing.nvim

### Usage

```lua
vim.ui.input = function(...)
  require('gizmos.input')(...)
end
```
