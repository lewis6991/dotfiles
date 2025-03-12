-- install with:
--   npm i -g bash-language-server
-- also uses shellcheck if installed:
--   brew install shellcheck
return {
  cmd = { 'bash-language-server', 'start' },
  filetypes = { 'zsh', 'sh', 'bash' },
}
