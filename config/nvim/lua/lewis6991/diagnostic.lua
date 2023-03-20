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

local function filter_unecessary(diag, include)
  return vim.tbl_filter(function(x)
    if x.user_data
        and x.user_data.lsp
        and x.user_data.lsp.tags
        and x.user_data.lsp.tags[1] == 1 then
      return include
    end
    return not include
  end, diag)
end

for _, t in ipairs{ 'signs', 'virtual_text', 'underline' } do
  local orig_handler = handlers[t]
  handlers[t] = {
    show = function(ns, bufnr, diagnostics, opts)
      orig_handler.show(ns, bufnr, filter_unecessary(diagnostics, false), opts)
    end,

    hide = orig_handler.hide
  }
end

local ns = vim.api.nvim_create_namespace('diag-unnecessary')

-- see https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#diagnosticTag
-- and https://github.com/microsoft/pyright/issues/1118#issuecomment-835528161
handlers.unnecessary = {
  show = function(_, bufnr, diagnostics, _opts)
    diagnostics = filter_unecessary(diagnostics, true)
    for _, d in ipairs(diagnostics) do
      vim.highlight.range(bufnr, ns, 'DiagnosticHint',
        { d.lnum, d.col }, { d.end_lnum, d.end_col },
        { priority = vim.highlight.priorities.diagnostics }
      )
    end
  end,

  hide = function(_, bufnr)
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  end,
}
