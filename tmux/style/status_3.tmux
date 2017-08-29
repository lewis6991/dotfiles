COLOUR_BG="colour18"
COLOUR_FG_1="colour15"
COLOUR_FG_2="colour8"

set -g status-interval              1
set -g status-justify               centre
set -g status-fg                    $COLOUR_FG_1
set -g status-bg                    $COLOUR_BG

set -g status-left \
'  #[fg=colour8]#(exec tmux ls | cut -d " " -f 1 | tr "\\n" " " | sed "s/://g") \
  #[fg=colour15]#{session_name}  '

set -g status-left-fg               $COLOUR_FG_1
set -g status-left-bg               $COLOUR_BG
set -g status-left-attr             dim
set -g status-left-length           100

set -g window-status-format         '  #{window_name}  '
set -g window-status-fg             $COLOUR_FG_2
set -g window-status-attr           dim

set -g window-status-current-format '  #{window_name}  '
set -g window-status-current-fg     $COLOUR_BG
set -g window-status-current-bg     $COLOUR_FG_2
set -g window-status-current-attr   bold

set -g window-status-separator      ''

set -g status-right '#(exec ~/bin/bitcoin_price.sh)    %a %e %b  %H:%M  '

set -g status-right-fg              $COLOUR_FG_2
set -g status-right-bg              $COLOUR_BG
set -g status-right-length          100
set -g status-right-attr            bold

set -g status-position bottom

set -g pane-border-fg        $COLOUR_BG
set -g pane-active-border-fg $COLOUR_FG_2
# set -g pane-active-border-fg $COLOUR_BG

# vim:set ft=tmux:
