if has('nvim')
    execute 'luafile ' . stdpath('config') . '/lua/plugins.lua'
end
