
function! s:hunks() abort
    if exists('b:gitsigns_status')
        let status = b:gitsigns_head
        if b:gitsigns_status !=# ''
            let status .= ' '.b:gitsigns_status
        endif
        return status
    endif
    return ''
endfunction

function! s:encodingAndFormat() abort
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

    let sl = luaeval('_G.Lsp_status and Lsp_status() or "NA"')
    if sl !=# ''
        let sl = '  '.sl.'  '
    end
    return sl
endfunction

function! s:statusline(active) abort
    let sid = expand('<SID>')
    let s  = '%#StatusLine#'
    let s .= s:status_highlight(1, a:active)
    let s .= s:recording()
    let s .= '%( %{'.sid.'hunks()}  %)'
    let s .= s:status_highlight(2, a:active)
    let s .= s:lsp_status()
    if exists('*metals#status')
        let s .= '%( %{metals#status()}  %)'
    end
    let s .= '%='
    let s .= '%<%0.60f%m%r'  " file.txt[+][RO]
    let s .= ' %= '

    " filetype
    let s .= '%( %{&filetype} %)'
    if exists('*WebDevIconsGetFileTypeSymbol')
        let s .= '%( %{WebDevIconsGetFileTypeSymbol()} %)'
    endif

    let s .= ' '.s:status_highlight(1, a:active).' '

    " encoding
    let s .= '%( %{'.sid.'encodingAndFormat()}%)'
    if exists('*WebDevIconsGetFileFormatSymbol')
        let s .= '%( %{WebDevIconsGetFileFormatSymbol()}%)'
    endif

    let s .= '%3p%% %2l(%02c)/%-3L ' " 80% 65[12]/120
    return s
endfunction

function! s:statusline_expr(active) abort
    return '%!'.expand('<SID>')..'statusline('.a:active.')'
endfunction

augroup statusline
    " Only set up WinEnter autocmd when the WinLeave autocmd runs
    autocmd WinEnter,FocusGained * let &l:statusline=s:statusline_expr(1)
    autocmd WinLeave,FocusLost   * let &l:statusline=s:statusline_expr(0)
augroup END

let &statusline=s:statusline_expr(1)
