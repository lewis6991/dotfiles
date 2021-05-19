
local linters = {}

linters.jenkinsfile_validate = {
  sourceName = 'jenkinsfile_validate',
  command = 'java',
  args = {'-jar', os.getenv('JENKINS_CLI'), 'declarative-linter'},
  formatPattern = {
    '^WorkflowScript: \\d+: (.+) @ line (\\d+), column (\\d+)\\.$', {
      message = 1, line = 2, column = 3,
    }
  },
}

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

linters.pylint = {
  sourceName = "pylint",
  command = "pylint",
  args = {"--output-format=json", '--from-stdin', '%filepath'},
  rootPatterns = {"pylintrc", "pyproject.toml", ".git"},
  parseJson = {
    line       = 'line',
    column     = 'column',
    security   = 'type',
    message    = '${message-id}: ${message}'
  },
  offsetColumn = 1,
  securities = {
    informational = "hint",
    refactor      = "info",
    convention    = "warning",
    warning       = "warning",
    error         = "error",
    fatal         = "error"
  },
}

linters.mypy = {
  offsetColumn = 0,
  sourceName = "mypy",
  command = "mypy",
  args = {
    '--shadow-file', '%filepath', '%tempfile', '%filepath',
    '--python-version=3.8',
    '--show-error-codes',
    '--show-column-numbers',
    '--strict'
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
}

linters.tealcheck = {
  sourceName = "tealcheck",
  command = "tl",
  args = {'check', '%file'},
  isStdout = false,
  isStderr = true,
  rootPatterns = {"tlconfig.lua", ".git"},
  formatPattern = {
    '^([^:]+):(\\d+):(\\d+): (.+)$',
    {
      sourceName = 1,
      sourceNameFilter = true,
      line = 2,
      column = 3,
      message = 4
    }
  }
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
