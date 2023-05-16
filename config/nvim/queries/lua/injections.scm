;; extends

; pcall(exec_lua, [[code]])
(
  (function_call
    (identifier)
    (arguments
      (identifier) @_exec_lua
      (string) @lua
    )
  )
  (#eq? @_exec_lua "exec_lua")
  (#lua-match? @lua "^%[%[")
  (#offset! @lua 0 2 0 -2)
)

(
  (function_call
    (identifier) @_exec_lua
    (arguments
      (string) @lua)
  )

  (#eq? @_exec_lua "exec_lua")
  (#lua-match? @lua "^%[%[")
  (#offset! @lua 0 2 0 -2)
)

(
  (function_call
    (identifier) @_exec_lua
    (arguments
      (string) @lua)
  )

  (#eq? @_exec_lua "exec_lua")
  (#lua-match? @lua "^%[=%[")
  (#offset! @lua 0 3 0 -3)
)

(
  (function_call
    (identifier) @_exec
    (arguments
      (string) @vim)
  )

  (#eq? @_exec "exec")
  (#lua-match? @vim "^%[%[")
  (#offset! @vim 0 2 0 -2)
)

(
  (function_call
    (identifier) @_exec_lua
    (arguments
      (string) @lua)
  )

  (#eq? @_exec_lua "exec_lua")
  (#lua-match? @lua "^[\"']")
  (#offset! @lua 0 1 0 -1)
)

(
  (function_call
    (identifier) @_exec
    (arguments
      (string) @vim)
  )

  (#eq? @_exec "exec")
  (#lua-match? @vim "^[\"']")
  (#offset! @vim 0 1 0 -1)
)
