# `lsp_lua_auto_require.lua`

Automatically adds paths to `workspace.library` when a `require` is detected in the buffer.

Leaner/simpler version https://github.com/folke/lazydev.nvim

### Usage

```lua
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'lua auto require',
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client.name == 'luals' then
      require('gizmos.lsp_lua_auto_require')(client, args.buf)
    end
  end,
})
```
