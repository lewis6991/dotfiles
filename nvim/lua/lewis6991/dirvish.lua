vim.g.dirvish_mode = ':sort ,^.*[\\/],'

function Dirvish_open(cmd, bg)
    local path = vim.fn.getline('.')
    if vim.fn.isdirectory(path) == 1 then
        if cmd == 'edit' and not bg then
            vim.fn['dirvish#open'](cmd, 0)
        end
    else
        if bg then
            vim.fn['dirvish#open'](cmd, 1)
        else
            vim.cmd'bwipeout'
            vim.cmd(cmd..' '..path)
        end
    end
end

function Dirvish_toggle()
    local lines   = vim.o.lines
    local columns = vim.o.columns
    local width   = vim.fn.float2nr(columns * 0.3)
    local height  = vim.fn.float2nr(lines * 0.8)
    local top     = ((lines - height) / 2) - 1
    local left    = columns - width
    local path    = vim.fn.expand('%:p')
    local fdir    = vim.fn.expand('%:h')
    vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), true, {
          relative = 'editor',
          row      = top,
          col      = left,
          width    = width,
          height   = height,
          style    = 'minimal',
          border   = 'single'
        })

    if fdir == '' then
        fdir = '.'
    end

    vim.fn['dirvish#open'](fdir)

    if path ~= '' then
        vim.fn.search('\\V\\^'..vim.fn.escape(path, '\\')..'\\$', 'cw')
    end
end

vim.cmd[[nmap <silent> - :<C-U>lua Dirvish_toggle()<CR>]]

vim.cmd[[augroup dirvish_config | augroup END]]
vim.cmd[[autocmd dirvish_config FileType dirvish nmap <silent> <buffer> <CR>  :<C-U>lua Dirvish_open('edit'   , false)<CR>]]
vim.cmd[[autocmd dirvish_config FileType dirvish nmap <silent> <buffer> v     :<C-U>lua Dirvish_open('vsplit' , false)<CR>]]
vim.cmd[[autocmd dirvish_config FileType dirvish nmap <silent> <buffer> V     :<C-U>lua Dirvish_open('vsplit' , true)<CR>]]
vim.cmd[[autocmd dirvish_config FileType dirvish nmap <silent> <buffer> s     :<C-U>lua Dirvish_open('split'  , false)<CR>]]
vim.cmd[[autocmd dirvish_config FileType dirvish nmap <silent> <buffer> S     :<C-U>lua Dirvish_open('split'  , true)<CR>]]
vim.cmd[[autocmd dirvish_config FileType dirvish nmap <silent> <buffer> t     :<C-U>lua Dirvish_open('tabedit', false)<CR>]]
vim.cmd[[autocmd dirvish_config FileType dirvish nmap <silent> <buffer> T     :<C-U>lua Dirvish_open('tabedit', true)<CR>]]
vim.cmd[[autocmd dirvish_config FileType dirvish nmap <silent> <buffer> -     <Plug>(dirvish_up)]]
vim.cmd[[autocmd dirvish_config FileType dirvish nmap <silent> <buffer> <ESC> :bd<CR>]]
vim.cmd[[autocmd dirvish_config FileType dirvish nmap <silent> <buffer> q     :bd<CR>]]
vim.cmd[[autocmd dirvish_config FileType dirvish nmap <buffer> <C-w> <nop>]]
vim.cmd[[autocmd dirvish_config FileType dirvish nmap <buffer> <C-h> <nop>]]
vim.cmd[[autocmd dirvish_config FileType dirvish nmap <buffer> <C-j> <nop>]]
vim.cmd[[autocmd dirvish_config FileType dirvish nmap <buffer> <C-k> <nop>]]
vim.cmd[[autocmd dirvish_config FileType dirvish nmap <buffer> <C-l> <nop>]]
vim.cmd[[autocmd dirvish_config FileType dirvish setlocal nocursorline]]
