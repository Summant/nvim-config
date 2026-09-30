return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    { '<leader>f', function() require('conform').format { async = true, lsp_format = 'fallback' } end, mode = '', desc = '[F]ormat buffer' },
  },
  opts = {
    notify_on_error = false,
    -- format on save, except C/C++ (your original choice) — use <leader>f there
    format_on_save = function(bufnr)
      local disable = { c = true, cpp = true }
      if disable[vim.bo[bufnr].filetype] then return nil end
      return { timeout_ms = 500, lsp_format = 'fallback' }
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      c = { 'clang-format' },
      cpp = { 'clang-format' },
      python = { 'ruff_format' },
    },
  },
}
