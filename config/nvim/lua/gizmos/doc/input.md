# `input.lua`

Very usable but basic implementation of `vim.ui.input()`.

Stripped down version of https://github.com/stevearc/dressing.nvim

![image](https://github.com/user-attachments/assets/900ef0e5-0d3e-4019-8550-69f788c17514)

### Usage

```lua
vim.ui.input = function(...)
  require('gizmos.input')(...)
end
```
