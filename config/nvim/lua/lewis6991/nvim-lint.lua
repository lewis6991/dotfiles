local function do_setup()
  local nvimlint = require('lint')

  local linters = nvimlint.linters

  linters.jenkins_lint = {
    cmd = "java",
    args = {'-jar', os.getenv('JENKINS_CLI'), 'declarative-linter'},
    stdin = true,
    ignore_exitcode = true,
    parser = function(output)
      local diags = {} --- @type Diagnostic[]
      for _, line in ipairs(vim.split(output, "\n")) do
        local ok, _, msg, lnum, col = line:find('^WorkflowScript: %d+: (.+) @ line (%d+), column (%d+).')
        if ok then
          diags[#diags+1] = {
            lnum = tonumber(lnum - 1) --[[@as integer]],
            col = col - 1,
            message = msg,
            severity = 1,
            source = "Jenkins",
          }
        end
      end

      return diags
    end,
  }

  linters.tcl_lint = {
    cmd = 'make',
    stdin = false,
    append_fname = false,
    args = {'tcl_lint'},
    stream = 'stdout',
    ignore_exitcode = true, -- set this to true if the linter exits with a code != 0 and that's considered normal.
    parser = function(output, bufnr)
      local diags = {} --- @type Diagnostic[]
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      for _, line in ipairs(vim.split(output, "\n")) do
        local ok, _, path, lnum, sev, msg = line:find('^([^:]+): Line%s+(%d+): (.) (.+)$')
        if ok and vim.endswith(bufname, path) then
          diags[#diags+1] = {
            lnum = tonumber(lnum - 1) --[[@as integer]],
            col = 0,
            message = msg,
            severity = sev,
            source = "TCL",
          }
        end
      end

      return diags
    end,
  }

  nvimlint.linters_by_ft = {
    tcl = {'tcl_lint'},
    Jenkinsfile = {'jenkins_lint'}
  }
end

local did_setup = false

vim.api.nvim_create_autocmd({ 'FileType', 'BufWritePost', 'TextChanged', 'InsertLeave' }, {
  callback = function()
    if not did_setup then
      do_setup()
      did_setup = true
    end
    require("lint").try_lint()
  end,
})
