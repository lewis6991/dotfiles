return {
  cmd = { 'clangd', '--clang-tidy' },
  root_markers = { '.clangd', 'compile_commands.json' },
  filetypes = { 'c', 'cpp' },
}
