
function! Hunks() abort
    if exists('b:gitsigns_status')
        return b:gitsigns_status
    endif
    return ''
endfunction

function! EncodingAndFormat() abort
    let l:e = &fileencoding ? &fileencoding : &encoding
    let l:f = &fileformat

    if l:e ==# 'utf-8'
        let l:e = ''
    endif

    if l:f ==# 'unix'
        let l:f = ''
    else
        let l:f = '['.l:f.']'
    endif

    let r = join([l:e, l:f])

    if v:version >= 800
        let r = trim(r)
    end

    return r
endfunction

function! s:status_highlight(num, active) abort
    if a:active
        if   a:num == 1 | return '%#PmenuSel#'
        else            | return '%#StatusLine#'
        endif
    else
        return '%#StatusLineNC#'
    endif
endfunction

function! s:recording() abort
    if !exists('*reg_recording')
        return ''
    endif

    let reg = reg_recording()
    if reg !=# ''
        return '%#ModeMsg#  RECORDING['.reg.']  '
    else
        return ''
    endif
endfunction

function! s:lsp_status() abort
    if !has('nvim')
        return ''
    end

   " if exists('*metals#errors')
   "      return ' %{metals#errors()} %{metals#warnings()}'
   "  end

    let sl = ''
    if luaeval('not vim.tbl_isempty(vim.lsp.buf_get_clients(0))')
        let sl .= ' E:'
        let sl .= '%{luaeval("vim.lsp.diagnostic.get_count([[Error]])")}'
        let sl .= ' W:'
        let sl .= '%{luaeval("vim.lsp.diagnostic.get_count([[Warning]])")}'
    endif
    return sl
endfunction

function! s:filetype() abort
    let s = '%( %{&filetype} %)'
    if exists('*WebDevIconsGetFileTypeSymbol')
        let s .= '%( %{WebDevIconsGetFileTypeSymbol()} %)'
    endif
    return s
endfunction

function! s:fileformat() abort
    let s = '%( %{EncodingAndFormat()}%)'
    if exists('*WebDevIconsGetFileFormatSymbol')
        let s .= '%( %{WebDevIconsGetFileFormatSymbol()}%)'
    endif
    return s
endfunction

function! Statusline_expr(active) abort
    let s  = '%#StatusLine#'
    let s .= s:status_highlight(1, a:active)
    let s .= s:recording()
    let s .= '%( %{Hunks()}  %)'
    let s .= s:status_highlight(2, a:active)
    let s .= s:lsp_status()
    if exists('*metals#status')
        let s .= '%( %{metals#status()}  %)'
    end
    let s .= '%='
    let s .= '%<%0.60f%m%r'  " file.txt[+][RO]
    let s .= ' %= '
    let s .= s:filetype()
    let s .= ' '.s:status_highlight(1, a:active).' '
    let s .= s:fileformat()
    let s .= '%3p%% %2l(%02c)/%-3L ' " 80% 65[12]/120
    return s
endfunction

augroup statusline
    " Only set up WinEnter autocmd when the WinLeave autocmd runs
    autocmd WinLeave,FocusLost *
        \ setlocal statusline=%!Statusline_expr(0) |
        \ autocmd vimrc WinEnter,FocusGained *
            \ setlocal statusline=%!Statusline_expr(1)
augroup END

set statusline=%!Statusline_expr(1)
