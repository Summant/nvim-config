return {
  { 'NMAC427/guess-indent.nvim', opts = {} }, -- detect tabstop/shiftwidth per file
  { 'windwp/nvim-autopairs', event = 'InsertEnter', opts = {} },

  { -- git signs in the gutter
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      signs = {
        add = { text = '▎' }, change = { text = '▎' }, delete = { text = '' },
        topdelete = { text = '' }, changedelete = { text = '▎' }, untracked = { text = '▎' },
      },
      current_line_blame = false,
      on_attach = function(bufnr)
        local gs = require 'gitsigns'
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end
        map('n', ']c', function() gs.nav_hunk 'next' end, 'Jump to next git [c]hange')
        map('n', '[c', function() gs.nav_hunk 'prev' end, 'Jump to previous git [c]hange')
        map('n', '<leader>hs', gs.stage_hunk,   'git [s]tage hunk')
        map('n', '<leader>hr', gs.reset_hunk,   'git [r]eset hunk')
        map('n', '<leader>hp', gs.preview_hunk, 'git [p]review hunk')
        map('n', '<leader>hb', gs.blame_line,   'git [b]lame line')
        map('n', '<leader>hd', gs.diffthis,     'git [d]iff against index')
        map('n', '<leader>tb', gs.toggle_current_line_blame, '[T]oggle git [b]lame line')
      end,
    },
  },

  { -- indent guides, with the active scope highlighted
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      indent = { char = '│', highlight = 'IblIndent' },
      scope  = { char = '│', highlight = 'IblScope', show_start = false, show_end = false },
      exclude = { filetypes = { 'help', 'dashboard', 'lazy', 'mason', 'NvimTree', 'trouble', 'checkhealth' } },
    },
    config = function(_, opts)
      vim.api.nvim_set_hl(0, 'IblIndent', { fg = '#241f33' })
      vim.api.nvim_set_hl(0, 'IblScope',  { fg = '#7a1fff' })
      require('ibl').setup(opts)
    end,
  },

  { -- show hex/rgb colours inline — handy for editing hyprland.lua, waybar css, kitty.conf
    'catgoose/nvim-colorizer.lua',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      filetypes = { '*' },
      user_default_options = {
        names = false,          -- don't colour the word "red" in prose
        css = true, css_fn = true,
        mode = 'virtualtext', virtualtext = '󰝤 ',
        tailwind = false,
      },
    },
  },

  { -- diagnostics / quickfix / references in a proper panel
    'folke/trouble.nvim',
    cmd = 'Trouble',
    opts = { focus = true },
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>',              desc = 'Diagnostics (workspace)' },
      { '<leader>xb', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Diagnostics (buffer)' },
      { '<leader>xs', '<cmd>Trouble symbols toggle<cr>',                  desc = 'Symbols outline' },
      { '<leader>xq', '<cmd>Trouble qflist toggle<cr>',                   desc = 'Quickfix list' },
    },
  },

  { -- dashboard, indent-aware scrolling, notifications, lazygit, big-file guard
    'folke/snacks.nvim',
    priority = 900,
    lazy = false,
    keys = {
      { '<leader>gg', function() Snacks.lazygit() end,      desc = 'Lazy[g]it' },
      { '<leader>gb', function() Snacks.git.blame_line() end, desc = 'Git [b]lame line' },
      { '<leader>un', function() Snacks.notifier.hide() end, desc = 'Dismiss notifications' },
      { '<leader>.',  function() Snacks.scratch() end,       desc = 'Scratch buffer' },
    },
    opts = {
      bigfile  = { enabled = true },  -- disable heavy features on huge files
      quickfile = { enabled = true },
      notifier = { enabled = true, timeout = 2500, style = 'compact' },
      input    = { enabled = true },
      styles = {
        notification = { wo = { winblend = 0 } },
      },
      dashboard = {
        enabled = true,
        preset = {
          header = table.concat({
            '                                                  ',
            '  ███╗   ██╗██╗   ██╗██╗███╗   ███╗               ',
            '  ████╗  ██║██║   ██║██║████╗ ████║               ',
            '  ██╔██╗ ██║██║   ██║██║██╔████╔██║               ',
            '  ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║               ',
            '  ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║               ',
            '  ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝               ',
          }, '\n'),
          keys = {
            { icon = ' ', key = 'f', desc = 'Find file',    action = ':lua Snacks.dashboard.pick("files")' },
            { icon = ' ', key = 'n', desc = 'New file',     action = ':ene | startinsert' },
            { icon = ' ', key = 'g', desc = 'Grep text',    action = ':lua Snacks.dashboard.pick("live_grep")' },
            { icon = ' ', key = 'r', desc = 'Recent files', action = ':lua Snacks.dashboard.pick("oldfiles")' },
            { icon = ' ', key = 'c', desc = 'Config',       action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = '󰒲 ', key = 'l', desc = 'Lazy',         action = ':Lazy' },
            { icon = ' ', key = 'q', desc = 'Quit',         action = ':qa' },
          },
        },
        sections = {
          { section = 'header' },
          { section = 'keys',   gap = 1, padding = 1 },
          { section = 'startup' },
        },
      },
    },
  },
}
