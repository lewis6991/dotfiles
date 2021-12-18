
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
  (#lua-match? @lua "^[\"']")
  (#offset! @lua 0 1 0 -1)
)
