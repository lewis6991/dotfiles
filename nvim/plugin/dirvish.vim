
let g:dirvish_mode = ':sort ,^.*[\/],'

nmap <silent> - :<C-U>call <SID>dirvish_toggle()<CR>

function! s:dirvish_open(cmd, bg) abort "{{{
    let path = getline('.')
    if isdirectory(path)
        if a:cmd ==# 'edit' && a:bg ==# '0'
            call dirvish#open(a:cmd, 0)
        endif
    else
        if a:bg
            call dirvish#open(a:cmd, 1)
        else
            bwipeout
            execute a:cmd ' ' path
        endif
    endif
endfunction "}}}

" call dirvish#add_icon_fn({p -> WebDevIconsGetFileTypeSymbol(p).' '})

function! s:dirvish_toggle() abort "{{{
    let width  = float2nr(&columns * 0.5)
    let height = float2nr(&lines * 0.8)
    let top    = ((&lines - height) / 2) - 1
    let left   = (&columns - width) / 2
    let opts   = {'relative': 'editor', 'row': top, 'col': left, 'width': width, 'height': height, 'style': 'minimal' }
    let fdir = expand('%:h')
    let path = expand('%:p')
    call nvim_open_win(nvim_create_buf(v:false, v:true), v:true, opts)
    if fdir ==# ''
        let fdir = '.'
    endif

    call dirvish#open(fdir)

    if !empty(path)
        call search('\V\^'.escape(path, '\').'\$', 'cw')
    endif
endfunction "}}}

augroup dirvish_config
    autocmd FileType dirvish nmap <silent> <buffer> <CR>  :<C-U>call <SID>dirvish_open('edit'   , 0)<CR>
    autocmd FileType dirvish nmap <silent> <buffer> v     :<C-U>call <SID>dirvish_open('vsplit' , 0)<CR>
    autocmd FileType dirvish nmap <silent> <buffer> V     :<C-U>call <SID>dirvish_open('vsplit' , 1)<CR>
    autocmd FileType dirvish nmap <silent> <buffer> s     :<C-U>call <SID>dirvish_open('split'  , 0)<CR>
    autocmd FileType dirvish nmap <silent> <buffer> S     :<C-U>call <SID>dirvish_open('split'  , 1)<CR>
    autocmd FileType dirvish nmap <silent> <buffer> t     :<C-U>call <SID>dirvish_open('tabedit', 0)<CR>
    autocmd FileType dirvish nmap <silent> <buffer> T     :<C-U>call <SID>dirvish_open('tabedit', 1)<CR>
    autocmd FileType dirvish nmap <silent> <buffer> -     <Plug>(dirvish_up)
    autocmd FileType dirvish nmap <silent> <buffer> <ESC> :bd<CR>
    autocmd FileType dirvish nmap <silent> <buffer> q     :bd<CR>

    autocmd FileType dirvish nmap <buffer> <C-w> <nop>
    autocmd FileType dirvish nmap <buffer> <C-h> <nop>
    autocmd FileType dirvish nmap <buffer> <C-j> <nop>
    autocmd FileType dirvish nmap <buffer> <C-k> <nop>
    autocmd FileType dirvish nmap <buffer> <C-l> <nop>

    autocmd FileType dirvish setlocal nocursorline
augroup END
