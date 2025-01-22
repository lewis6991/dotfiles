local env = vim.env

local jenkins_lint --- @type table<string,any>
if env.JENKINS_CLI and env.JENKINS_URL and env.JENKINS_USER and env.JENKINS_AUTH_TOKEN then
  jenkins_lint = {
    cmd = 'java',
    args = {
      '-jar',
      env.JENKINS_CLI,
      '-s',
      env.JENKINS_URL,
      '-noCertificateCheck',
      '-auth',
      env.JENKINS_USER .. ':' .. env.JENKINS_AUTH_TOKEN,
      'declarative-linter',
    },
    stdin = true,
    ignore_exitcode = true,
    parser = function(output)
      local diags = {} --- @type vim.Diagnostic[]
      for _, line in ipairs(vim.split(output, '\n')) do
        local ok, _, msg, lnum, col =
          line:find('^WorkflowScript: %d+: (.+) @ line (%d+), column (%d+).')
        if ok then
          diags[#diags + 1] = {
            lnum = tonumber(lnum - 1) --[[@as integer]],
            col = col - 1,
            message = msg,
            severity = 1,
            source = 'Jenkins',
          }
        end
      end

      return diags
    end,
  }
end

local tcl_lint = {
  cmd = 'make',
  stdin = false,
  append_fname = false,
  args = { 'tcl_lint' },
  stream = 'stdout',
  ignore_exitcode = true, -- set this to true if the linter exits with a code != 0 and that's considered normal.
  parser = function(output, bufnr)
    local diags = {} --- @type vim.Diagnostic[]
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    for _, line in ipairs(vim.split(output, '\n')) do
      local ok, _, path, lnum, sev, msg = line:find('^([^:]+): Line%s+(%d+): (.) (.+)$')
      if ok and vim.endswith(bufname, path) then
        diags[#diags + 1] = {
          lnum = tonumber(lnum - 1) --[[@as integer]],
          col = 0,
          message = msg,
          severity = sev,
          source = 'TCL',
        }
      end
    end

    return diags
  end,
}

local function do_setup()
  local nvimlint = require('lint')

  local linters = nvimlint.linters

  linters.jenkins_lint = jenkins_lint
  linters.tcl_lint = tcl_lint

  nvimlint.linters_by_ft = {
    tcl = { 'tcl_lint' },
    Jenkinsfile = jenkins_lint and { 'jenkins_lint' } or nil,
    python = { 'pylint' },
  }
end

local did_setup = false

vim.api.nvim_create_autocmd({ 'FileType', 'BufWritePost', 'CursorHold' }, {
  callback = function()
    if not did_setup then
      do_setup()
      did_setup = true
    end
    require('lint').try_lint()
  end,
})
