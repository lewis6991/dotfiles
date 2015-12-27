#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––#
# Prompt                                                                       #
#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––#
function fish_prompt

    if test $status -eq 0
        set_color green
    else
        set_color red
    end

    echo -n $USER':'
    set_color purple

    if test $PWD = $HOME
        echo -n '~'
    else
        echo -n (basename $PWD)
    end

    set_color yellow
    echo -n '>> '

    set_color normal
end

#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––#
# Aliases                                                                      #
#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––#
alias ll 'ls -goAh'

if brew --prefix coreutils >/dev/null
    alias ls 'ls --color'
    alias ll 'ls -goAh --group-directories-first'
end

if which nvim >/dev/null
    alias vim 'nvim'
end

alias ..   'cd ..'
alias ...  'cd ../..'
alias .... 'cd ../../..'
