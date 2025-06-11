# `luals_setup.lua`

Automatically adds paths to `workspace.library` when a `require` is detected in the buffer.

Leaner/simpler version https://github.com/folke/lazydev.nvim

### Usage

```lua
require('gizmos.luals_setup')()
-- require('gizmos.luals_setup')('lua_ls') -- if using lspconfig
```
