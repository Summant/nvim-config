-- nvim-treesitter `main` branch (the rewrite): parsers are installed with the tree-sitter CLI and
-- highlighting/indent are enabled through Neovim's built-in APIs.
return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    local ts = require 'nvim-treesitter'
    ts.setup {}
    local langs = { 'bash', 'c', 'cpp', 'diff', 'html', 'json', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'python', 'query', 'toml', 'vim', 'vimdoc', 'yaml' }
    ts.install(langs)

    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('treesitter-start', { clear = true }),
      callback = function(ev)
        -- start highlighting if a parser exists for this filetype (silently skip otherwise)
        if pcall(vim.treesitter.start, ev.buf) then
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
