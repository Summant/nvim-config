return {
  { -- colourscheme: tokyonight-night, transparent so kitty's 0.94 opacity and the
    -- wallpaper show through, with the desktop's purple/blue accents layered on top.
    'folke/tokyonight.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      style = 'night',
      transparent = true,
      styles = {
        comments = { italic = false },
        sidebars = 'transparent',
        floats = 'transparent',
      },
      on_colors = function(c)
        c.border_highlight = '#7a1fff' -- Hyprland's active-border purple
        c.border = '#2e2a3d'
      end,
      on_highlights = function(hl, c)
        -- keep every surface unpainted so nothing breaks the translucency
        for _, g in ipairs {
          'Normal', 'NormalNC', 'NormalFloat', 'FloatBorder', 'SignColumn',
          'LineNr', 'FoldColumn', 'VertSplit', 'WinSeparator', 'StatusLine',
          'TabLine', 'TabLineFill', 'Pmenu', 'TelescopeNormal', 'TelescopeBorder',
          'NvimTreeNormal', 'NvimTreeNormalNC', 'NvimTreeWinSeparator',
        } do
          hl[g] = vim.tbl_extend('force', hl[g] or {}, { bg = 'NONE' })
        end
        hl.FloatBorder    = { fg = '#2e2a3d', bg = 'NONE' }
        hl.WinSeparator   = { fg = '#2e2a3d', bg = 'NONE' }
        hl.CursorLine     = { bg = '#15121f' }       -- just enough to see the line
        hl.CursorLineNr   = { fg = '#7a1fff', bold = true }
        hl.Visual         = { bg = '#2a1a4a' }
        hl.PmenuSel       = { bg = '#7a1fff', fg = '#ffffff', bold = true }
        hl.PmenuThumb     = { bg = '#7a1fff' }
        hl.Search         = { bg = '#2a1a4a', fg = c.fg }
        hl.IncSearch      = { bg = '#7a1fff', fg = '#ffffff' }
        hl.MatchParen     = { fg = '#8ec9ff', bold = true }
        hl.TelescopeSelection      = { bg = '#1a1626', fg = '#ffffff', bold = true }
        hl.TelescopeMatching       = { fg = '#8ec9ff', bold = true }
        hl.TelescopePromptPrefix   = { fg = '#7a1fff' }
        hl.TelescopeTitle          = { fg = '#7a1fff', bold = true }
      end,
    },
    config = function(_, opts)
      require('tokyonight').setup(opts)
      vim.cmd.colorscheme 'tokyonight-night'
    end,
  },

  { -- statusline, themed to match waybar
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = 'VeryLazy',
    opts = function()
      local p = {
        purple = '#7a1fff', blue = '#8ec9ff', fg = '#cfd8e3',
        muted = '#6b7280', bg = 'NONE', dark = '#1a1626',
      }
      local mode = { a = { fg = '#ffffff', bg = p.purple, gui = 'bold' },
                     b = { fg = p.blue,   bg = p.dark },
                     c = { fg = p.muted,  bg = p.bg } }
      return {
        options = {
          theme = {
            normal = mode,
            insert  = vim.tbl_deep_extend('force', mode, { a = { bg = p.blue, fg = '#0e0c16' } }),
            visual  = vim.tbl_deep_extend('force', mode, { a = { bg = '#bb9af7', fg = '#0e0c16' } }),
            replace = vim.tbl_deep_extend('force', mode, { a = { bg = '#ff5555', fg = '#ffffff' } }),
            command = vim.tbl_deep_extend('force', mode, { a = { bg = '#e0af68', fg = '#0e0c16' } }),
            inactive = { a = { fg = p.muted, bg = p.bg }, b = { fg = p.muted, bg = p.bg }, c = { fg = p.muted, bg = p.bg } },
          },
          component_separators = '',
          section_separators = { left = '', right = '' },
          globalstatus = true,
        },
        sections = {
          lualine_a = { { 'mode', fmt = function(s) return ' ' .. s:sub(1, 1) end } },
          lualine_b = { { 'branch', icon = '' }, { 'diff', symbols = { added = '+', modified = '~', removed = '-' } } },
          lualine_c = { { 'filename', path = 1, symbols = { modified = ' ●', readonly = ' ' } } },
          lualine_x = {
            { 'diagnostics', symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' } },
            { function() -- Jupyter kernel, when one is running
                local ok, nb = pcall(require, 'config.notebook')
                return (ok and nb.status()) or ''
              end, color = { fg = '#8ec9ff' } },
            { function() -- which LSPs are attached
                local names = {}
                for _, c in pairs(vim.lsp.get_clients { bufnr = 0 }) do names[#names + 1] = c.name end
                return #names > 0 and ('  ' .. table.concat(names, ' ')) or ''
              end, color = { fg = p.muted } },
            { 'filetype', icon_only = true },
          },
          lualine_y = { { 'progress' } },
          lualine_z = { { 'location' } },
        },
        extensions = { 'nvim-tree', 'lazy', 'mason', 'trouble', 'quickfix' },
      }
    end,
  },

  { -- open buffers as tabs along the top
    'akinsho/bufferline.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = 'VeryLazy',
    keys = {
      { '<S-h>', '<cmd>BufferLineCyclePrev<cr>', desc = 'Previous buffer' },
      { '<S-l>', '<cmd>BufferLineCycleNext<cr>', desc = 'Next buffer' },
      { '<leader>bd', '<cmd>bdelete<cr>',        desc = '[B]uffer [D]elete' },
      { '<leader>bp', '<cmd>BufferLineTogglePin<cr>', desc = '[B]uffer [P]in' },
    },
    opts = {
      options = {
        diagnostics = 'nvim_lsp',
        separator_style = 'thin',
        show_buffer_close_icons = false,
        offsets = { { filetype = 'NvimTree', text = 'Files', highlight = 'Directory', separator = true } },
      },
      highlights = {
        fill                = { bg = 'NONE' },
        background          = { bg = 'NONE', fg = '#6b7280' },
        buffer_selected     = { bg = 'NONE', fg = '#ffffff', bold = true },
        buffer_visible      = { bg = 'NONE', fg = '#9aa4b1' },
        separator           = { bg = 'NONE', fg = '#2e2a3d' },
        separator_selected  = { bg = 'NONE', fg = '#7a1fff' },
        separator_visible   = { bg = 'NONE', fg = '#2e2a3d' },
        indicator_selected  = { bg = 'NONE', fg = '#7a1fff' },
        modified            = { bg = 'NONE', fg = '#8ec9ff' },
        modified_selected   = { bg = 'NONE', fg = '#8ec9ff' },
        close_button        = { bg = 'NONE' },
        close_button_visible= { bg = 'NONE' },
        close_button_selected = { bg = 'NONE' },
      },
    },
  },

  { -- pending-keybind popup
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      preset = 'modern',
      delay = 200,
      icons = { mappings = vim.g.have_nerd_font },
      spec = {
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { '<leader>d', group = '[D]ebug' },
        { '<leader>b', group = '[B]uffer' },
        { '<leader>x', group = 'Diagnostics' },
        { '<leader>j', group = '[J]upyter / notebook' },
      },
    },
  },

  { -- file explorer
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    cmd = { 'NvimTreeToggle', 'NvimTreeFocus' },
    keys = { { '<leader>e', '<cmd>NvimTreeToggle<CR>', desc = 'Toggle file [E]xplorer' } },
    opts = {
      view = { width = 34, signcolumn = 'no' },
      renderer = {
        group_empty = true,
        indent_markers = { enable = true },
        icons = { git_placement = 'right_align' },
      },
      filters = { dotfiles = false, custom = { '^.git$' } },
      git = { enable = true },
      diagnostics = { enable = true, show_on_dirs = true },
    },
  },

  { -- text objects + surround (statusline now comes from lualine)
    'nvim-mini/mini.nvim',
    event = 'VeryLazy',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()
    end,
  },

  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = true } },
  { 'j-hui/fidget.nvim', opts = { notification = { window = { winblend = 0 } } } },
}
