vim.diagnostic.config({
  -- virtual_text = { source = true },
  virtual_text = false,
  severity_sort = true,
  update_in_insert = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '●',
      [vim.diagnostic.severity.WARN] = '●',
      [vim.diagnostic.severity.INFO] = '●',
      [vim.diagnostic.severity.HINT] = '○',
    },
  },
  jump = {
    float = true
  }
})

vim.api.nvim_set_hl(0, 'LspCodeLens', { link = 'WarningMsg' })

local handlers = vim.diagnostic.handlers

local orig_signs_handler = handlers.signs

-- Override the built-in signs handler to aggregate signs
handlers.signs = {
  show = function(ns, bufnr, diagnostics, opts)
    -- Find the "worst" diagnostic per line
    local max_severity_per_line = {} --- @type table<integer,vim.Diagnostic>
    for _, d in pairs(diagnostics) do
      local m = max_severity_per_line[d.lnum]
      if not m or d.severity < m.severity then
        max_severity_per_line[d.lnum] = d
      end
    end

    -- Pass the filtered diagnostics (with our custom namespace) to
    -- the original handler
    local filtered_diagnostics = vim.tbl_values(max_severity_per_line)
    orig_signs_handler.show(ns, bufnr, filtered_diagnostics, opts)
  end,

  hide = orig_signs_handler.hide,
}
