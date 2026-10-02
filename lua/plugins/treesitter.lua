-- Treesitter: real syntax understanding — accurate highlighting, indentation,
-- and the sticky context header. Uses the rewritten `main` branch, where parsers
-- are installed with the tree-sitter CLI and features start from Neovim's own APIs.
return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local ts = require 'nvim-treesitter'
      ts.setup {}
      ts.install {
        'bash', 'c', 'cpp', 'css', 'diff', 'git_config', 'gitcommit', 'gitignore',
        'go', 'html', 'javascript', 'json', 'lua', 'luadoc', 'make',
        'markdown', 'markdown_inline', 'python', 'query', 'regex', 'rust',
        'toml', 'tsx', 'typescript', 'vim', 'vimdoc', 'yaml',
      }

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('treesitter-start', { clear = true }),
        callback = function(ev)
          -- start highlighting when a parser exists for this filetype; silently skip otherwise
          if pcall(vim.treesitter.start, ev.buf) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          end
        end,
      })
    end,
  },

  { -- keeps the enclosing function/class pinned to the top of the window
    'nvim-treesitter/nvim-treesitter-context',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = { max_lines = 3, multiline_threshold = 1, separator = '─' },
    config = function(_, opts)
      require('treesitter-context').setup(opts)
      vim.api.nvim_set_hl(0, 'TreesitterContext', { bg = '#15121f' })
      vim.api.nvim_set_hl(0, 'TreesitterContextLineNumber', { fg = '#7a1fff' })
      vim.api.nvim_set_hl(0, 'TreesitterContextSeparator', { fg = '#2e2a3d' })
    end,
  },

  { -- matching brackets get matching colours
    'HiPhish/rainbow-delimiters.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      local hl = { 'RainbowPurple', 'RainbowBlue', 'RainbowCyan', 'RainbowViolet', 'RainbowTeal' }
      vim.api.nvim_set_hl(0, 'RainbowPurple', { fg = '#7a1fff' })
      vim.api.nvim_set_hl(0, 'RainbowBlue',   { fg = '#8ec9ff' })
      vim.api.nvim_set_hl(0, 'RainbowCyan',   { fg = '#7dcfff' })
      vim.api.nvim_set_hl(0, 'RainbowViolet', { fg = '#bb9af7' })
      vim.api.nvim_set_hl(0, 'RainbowTeal',   { fg = '#2ac3de' })
      require('rainbow-delimiters.setup').setup { highlight = hl }
    end,
  },
}
