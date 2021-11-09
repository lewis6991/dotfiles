
local linters = {}

linters.tcl_lint = {
  sourceName = "tcl_lint",
  command = "make",
  -- $file has not effect on the command it is just here to force stdio to
  -- be disabled so updates only occur on file write
  args = {'tcl_lint', 'LFILE=$file'},
  debounce = 1000,
  rootPatterns = {'Makefile'},
  requiredFile = {'nagelfar.syntax', 'nagelfar/nagelfar.tcl'},
  formatPattern = {
    '^([^:]+): Line (\\d+): (.) (.+)$', {
      sourceName = 1,
      sourceNameFilter = true,
      line = 2,
      security = 3,
      message = 4
    }
  },
  securities = {
    warning = "W",
    error   = "E",
  },
}

linters.mypy = {
  offsetColumn = 0,
  sourceName = "mypy",
  command = "dmypy",
  args = {
    'run', '--log-file=dmypy.log',
    '--',
    '--shadow-file', '%filepath', '%tempfile', '%dirname',
    '--python-version=3.8',
    '--show-error-codes',
    '--show-column-numbers'
  },
  rootPatterns = {"setup.cfg", ".git"},
  formatLines = 1,
  formatPattern = {
    '^([^:]+):(\\d+):(\\d+): ([^:]+): (.*)$',
    {
      sourceName = 1,
      sourceNameFilter = true,
      line = 2,
      column = 3,
      security = 4,
      message = 5
    }
  },
  securities = {
    error = "error",
  },
  on_attach = function()
    vim.cmd[[augroup LSPCONFIG
      autocmd!
      autocmd VimLeavePre * :silent! !dmypy stop
    augroup END]]
  end
}

linters.shellcheck = {
  sourceName = "shellcheck",
  command = "shellcheck",
  args = {'--shell=bash', '-f', 'json', '--exclude=1004,1091,2002,2016', '-'},
  parseJson = {
    line       = 'line',
    endLine    = 'endLine',
    column     = 'column',
    endColumn  = 'endColumn',
    security   = 'level',
    message    = '${message} [${code}]'
  },
  securities = {
    error   = "error",
    warning = "warning",
    info    = "info",
    hint    = "style",
  },
}

return linters
