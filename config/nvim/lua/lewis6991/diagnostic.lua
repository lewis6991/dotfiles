vim.diagnostic.config {
  virtual_text = { source = true },
  severity_sort = true,
  update_in_insert = true,
}

local function set_lsp_sign(name, text)
  vim.fn.sign_define(name, {text = text, texthl = name})
end

vim.api.nvim_set_hl(0, 'LspCodeLens', {link='WarningMsg'})

set_lsp_sign("DiagnosticSignError", "●")
set_lsp_sign("DiagnosticSignWarn" , "●")
set_lsp_sign("DiagnosticSignInfo" , "●")
set_lsp_sign("DiagnosticSignHint" , "○")

local handlers = vim.diagnostic.handlers

local orig_signs_handler = handlers.signs

-- Override the built-in signs handler to aggregate signs
handlers.signs = {
  show = function(ns, bufnr, diagnostics, opts)

    -- Find the "worst" diagnostic per line
    local max_severity_per_line = {}
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

  hide = orig_signs_handler.hide
}
