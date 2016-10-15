set -g status-interval              1
set -g status-justify               centre
set -g status-bg                    colour18
set -g status-fg                    colour7

set -g status-left '\
#[fg=colour18,bg=colour4,bold]  #{session_name}   \
#[fg=colour4,bg=colour18]'

set -g window-status-format         '  #{window_name}  '
set -g window-status-fg             colour7
set -g window-status-bg             colour18
set -g window-status-attr           dim

set -g window-status-current-format '  #{window_name}  '
set -g window-status-current-fg     colour7
set -g window-status-current-bg     colour19
set -g window-status-current-attr   bold

set -g window-status-separator      ''

set -g status-right '\
%a %e %b \
#[fg=colour19]#[fg=colour7,bg=colour19] %H:%M \
#[fg=colour4]#[bg=colour4,fg=colour18] #{host} '
set -g status-right-bg              colour18
set -g status-right-fg              colour7

# vim: set ft=tmux :
