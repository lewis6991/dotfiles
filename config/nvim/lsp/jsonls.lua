-- install with:
--   npm install -g vscode-langservers-extracted
return {
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = { 'json', 'jsonc' },
}
