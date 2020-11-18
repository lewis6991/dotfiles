if !has('nvim')
    finish
end

command! PackerInstall lua require('plugins').install()
command! PackerUpdate  lua require('plugins').update()
command! PackerSync    lua require('plugins').sync()
command! PackerClean   lua require('plugins').clean()
command! PackerCompile lua require('plugins').compile()

" Reload plugins.lua
autocmd BufWritePost plugins.lua lua package.loaded["plugins"] = nil; require("plugins")

" Recompile lazy loaders
autocmd BufWritePost plugins.lua PackerCompile

" Reload lazy loaders
autocmd BufWritePost plugins.lua runtime plugin/packer_compiled.vim
