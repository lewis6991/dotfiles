; extends

(
 (command
   name: (command_name) @command
   redirect: (herestring_redirect
               (string) @injection.content
               )
   )
 (#eq? @command "python3")
 (#offset! @injection.content 0 1 0 -1)
 (#set! injection.language "python")
 (#set! injection.include-children)
 )
