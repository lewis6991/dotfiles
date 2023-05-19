;; extends


(
  (redirected_statement
    body: (command
      name: (command_name (word) @_name)
    )
    redirect: (herestring_redirect
      (_) @injection.content
    )
  )
  (#set! injection.language "python")
  (#eq? @_name "python3")
  (#offset! @injection.content 0 1 0 -1)
)
