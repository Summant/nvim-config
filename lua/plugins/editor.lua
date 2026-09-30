return {
  { 'NMAC427/guess-indent.nvim', opts = {} }, -- detect tabstop/shiftwidth per file
  { 'windwp/nvim-autopairs', event = 'InsertEnter', opts = {} },

  { -- git signs in the gutter
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = require 'gitsigns'
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end
        map('n', ']c', function() gs.nav_hunk 'next' end, 'Jump to next git [c]hange')
        map('n', '[c', function() gs.nav_hunk 'prev' end, 'Jump to previous git [c]hange')
        map('n', '<leader>hs', gs.stage_hunk, 'git [s]tage hunk')
        map('n', '<leader>hr', gs.reset_hunk, 'git [r]eset hunk')
        map('n', '<leader>hp', gs.preview_hunk, 'git [p]review hunk')
        map('n', '<leader>hb', gs.blame_line, 'git [b]lame line')
        map('n', '<leader>hd', gs.diffthis, 'git [d]iff against index')
      end,
    },
  },
}
