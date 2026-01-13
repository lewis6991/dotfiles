local env = vim.env

--- @type gizmos.lint.Linter?
local jenkins_lint
if env.JENKINS_CLI and env.JENKINS_URL and env.JENKINS_USER and env.JENKINS_AUTH_TOKEN then
  jenkins_lint = {
    name = 'jenkins_lint',
    cmd = {
      'java',
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
    parser = function(_bufnr, output)
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
          }
        end
      end

      return diags
    end,
  }
end

--- @type gizmos.lint.Linter
local tcl_lint = {
  name = 'tcl_lint',
  cmd = { 'make', 'tcl_lint' },
  ignore_exitcode = true,
  parser = function(bufnr, output)
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
        }
      end
    end

    return diags
  end,
}

local did_setup = false

vim.api.nvim_create_autocmd({ 'InsertLeave', 'FileType', 'TextChanged', 'BufWrite' }, {
  callback = function()
    local lint = require('gizmos.lint')
    if not did_setup then
      lint.linters = {
        Jenkinsfile = { jenkins_lint },
        tcl = { tcl_lint },
        lua = { 'stylua' },
        -- python = { 'pylint' },
      }

      did_setup = true
    end
    lint.lint()
  end,
})
