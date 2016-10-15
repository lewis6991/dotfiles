set -g status-interval              1
set -g status-justify               centre
set -g status-fg                    colour20
set -g status-bg                    colour18

set -g status-left                  '  #{session_name}  '
set -g status-left-fg               colour7
set -g status-left-bg               colour19
set -g status-left-attr             dim

set -g window-status-format         '  #{window_name}  '
set -g window-status-fg             colour20
set -g window-status-attr           dim

set -g window-status-current-format '  #{window_name}  '
set -g window-status-current-fg     colour7
set -g window-status-current-bg     colour19
set -g window-status-current-attr   bold

set -g window-status-separator      ''

set -g status-right '\
  %H:%M  \
#[fg=colour18]│#[fg=colour20]  %a %e %b  \
#[fg=colour18]│#[fg=colour20]  #{host}  '

set -g status-right-fg              colour20
set -g status-right-bg              colour19

# vim: set ft=tmux :
