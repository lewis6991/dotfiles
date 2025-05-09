# `gizmos.nvim`

A collection of small plugins for Neovim.

Note: Some are experimental/WIP.

| Plugin                       | Description |
|------------------------------|-------------|
| [`lint.lua`]                 | General linter |
| [`input.lua`]                | Better `vim.ui.input()` |
| [`hashbang.lua`]             | Easily add hashbangs to buffers |
| [`lastplace.lua`]            | Open buffers to the last known cursor position |
| [`http_file_viewer.lua`]     | Support for opening http url buffers |
| [`lsp_cmds.lua`]             | Ex commands for LSP |
| [`lsp_lua_auto_require.lua`] | Auto add plugins to `workspace.library` |
| [`marksigns.lua`]            | Highlight `:mark`'s |
| [`ts_matchparen.lua`]        | Treessitter powered matchparen |

Maintained as separate plugins

| Plugin | Description |
|--------|-------------|
| [fileline.nvim] | When you open a [FILE]:[LINE], open file FILE at line LINE |
| [spaceless.nvim] | Strip trailing whitespace as you are editing |
| [whatthejump.nvim] | Show jump locations in a floating window |

# Requirements

Latest release of Neovim

<!-- links -->
[`lint.lua`]: doc/lint.md
[`input.lua`]: doc/input.md
[`hashbang.lua`]: doc/hashbang.md
[`lastplace.lua`]: doc/lastplace.md
[`http_file_viewer.lua`]: doc/http_file_viewer.md
[`lsp_cmds.lua`]: doc/lsp_cmds.md
[`lsp_lua_auto_require.lua`]: doc/lsp_lua_auto_require.md
[`marksigns.lua`]: doc/marksigns.md
[`ts_matchparen.lua`]: doc/ts_matchparen.md

[fileline.nvim]: https://github.com/lewis6991/fileline.nvim
[spaceless.nvim]: https://github.com/lewis6991/spaceless.nvim
[whatthejump.nvim]: https://github.com/lewis6991/whatthejump.nvim
