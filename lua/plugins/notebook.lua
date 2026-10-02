-- Jupyter notebooks (.ipynb): edit them as plain text, run cells against a real
-- kernel, and see output — including plots — inline.
--
--   jupytext.nvim  opens an .ipynb as a normal buffer and writes it back as JSON
--   molten-nvim    talks to a Jupyter kernel and renders the output in a float
--   image.nvim     draws images via kitty's graphics protocol
--
-- Needs these system packages (see README):
--   python-pynvim jupyter-nbformat python-jupyter-client python-ipykernel
--   python-pillow python-cairosvg python-pyperclip imagemagick
--   plus python-jupytext from the AUR
return {
  { -- read/write .ipynb as if it were a script
    'GCBallesteros/jupytext.nvim',
    lazy = false,
    opts = {
      style = 'markdown',        -- cells become ```python blocks under markdown headings
      output_extension = 'md',
      force_ft = 'markdown',
    },
  },

  { -- inline images (plots, LaTeX) using kitty's graphics protocol
    '3rd/image.nvim',
    build = false,               -- magick_cli backend shells out to `magick`; no luarock needed
    opts = {
      backend = 'kitty',
      processor = 'magick_cli',
      integrations = {
        markdown = { enabled = true, only_render_image_at_cursor = true, filetypes = { 'markdown', 'quarto' } },
      },
      max_width_window_percentage = 70,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', 'snacks_notif', '' },
    },
  },

  { -- Draws the markdown view as a notebook: each ```python fence becomes a
    -- shaded, bordered cell with a language label, headings get backgrounds, and
    -- the raw ``` delimiters are concealed. This is what turns jupytext's plain
    -- text back into something that reads like a notebook.
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    ft = { 'markdown', 'quarto', 'codecompanion' },
    opts = {
      render_modes = { 'n', 'c', 't' },   -- keep raw text visible while editing (insert mode)
      anti_conceal = { enabled = true },  -- un-conceal the line the cursor is on
      heading = {
        sign = false,
        icons = { '󰎤 ', '󰎧 ', '󰎪 ', '󰎭 ', '󰎱 ', '󰎳 ' },
        backgrounds = { 'RMH1Bg', 'RMH2Bg', 'RMH3Bg', 'RMH4Bg', 'RMH5Bg', 'RMH6Bg' },
        foregrounds = { 'RMH1Fg', 'RMH2Fg', 'RMH3Fg', 'RMH4Fg', 'RMH5Fg', 'RMH6Fg' },
      },
      code = {
        sign = false,
        style = 'full',          -- language icon + name in the cell header
        width = 'block',         -- cell is as wide as its content, like a notebook
        left_pad = 2,
        right_pad = 2,
        min_width = 70,
        border = 'thick',
        highlight = 'RMCodeBg',
        highlight_inline = 'RMCodeInline',
      },
      bullet = { icons = { '•', '◦', '▸', '▪' } },
      checkbox = { unchecked = { icon = '󰄱 ' }, checked = { icon = '󰱒 ' } },
      quote = { icon = '▎' },
      pipe_table = { style = 'full', border_virtual = true },
      sign = { enabled = false },
    },
    config = function(_, opts)
      -- Palette matches the desktop: purple accent, light-blue secondary, and a
      -- cell background just light enough to read as a block over kitty's
      -- translucent background.
      local hl = vim.api.nvim_set_hl
      hl(0, 'RMCodeBg',     { bg = '#15121f' })
      hl(0, 'RMCodeInline', { bg = '#1a1626', fg = '#8ec9ff' })
      hl(0, 'RMH1Bg', { bg = '#241840' })
      hl(0, 'RMH2Bg', { bg = '#1e1733' })
      hl(0, 'RMH3Bg', { bg = '#1a1529' })
      hl(0, 'RMH4Bg', { bg = '#171320' })
      hl(0, 'RMH5Bg', { bg = '#15121c' })
      hl(0, 'RMH6Bg', { bg = '#141119' })
      hl(0, 'RMH1Fg', { fg = '#7a1fff', bold = true })
      hl(0, 'RMH2Fg', { fg = '#9d7bff', bold = true })
      hl(0, 'RMH3Fg', { fg = '#8ec9ff', bold = true })
      hl(0, 'RMH4Fg', { fg = '#7dcfff' })
      hl(0, 'RMH5Fg', { fg = '#9aa4b1' })
      hl(0, 'RMH6Fg', { fg = '#6b7280' })
      require('render-markdown').setup(opts)
    end,
  },

  { -- run cells against a Jupyter kernel
    'benlubas/molten-nvim',
    version = '^1.0.0',
    dependencies = { '3rd/image.nvim' },
    build = ':UpdateRemotePlugins',
    -- NOT lazy-loaded by filetype: molten is a *remote* plugin, so it must be on
    -- the runtimepath when :UpdateRemotePlugins scans, or it never registers and
    -- every :Molten* command silently does not exist. It costs nothing at startup —
    -- the python host only spawns on the first command.
    lazy = false,
    init = function()
      vim.g.molten_image_provider      = 'image.nvim'
      vim.g.molten_output_win_max_height = 24
      vim.g.molten_auto_open_output    = false  -- keep the float out of the way; <leader>jo shows it
      vim.g.molten_wrap_output         = true
      vim.g.molten_virt_text_output    = true   -- show results as virtual text under the cell
      vim.g.molten_virt_lines_off_by_1 = true
      vim.g.molten_output_virt_lines   = true
    end,
    keys = {
      { '<leader>ji', '<cmd>MoltenInit<cr>',              desc = '[J]upyter [i]nit kernel' },
      { '<leader>jl', '<cmd>MoltenEvaluateLine<cr>',      desc = '[J]upyter run [l]ine' },
      { '<leader>jr', '<cmd>MoltenReevaluateCell<cr>',    desc = '[J]upyter [r]e-run cell' },
      { '<leader>jo', '<cmd>noautocmd MoltenEnterOutput<cr>', desc = '[J]upyter [o]pen output' },
      { '<leader>jh', '<cmd>MoltenHideOutput<cr>',        desc = '[J]upyter [h]ide output' },
      { '<leader>jd', '<cmd>MoltenDelete<cr>',            desc = '[J]upyter [d]elete cell output' },
      { '<leader>jx', '<cmd>MoltenInterrupt<cr>',         desc = '[J]upyter interrupt' },
      { '<leader>jR', '<cmd>MoltenRestart!<cr>',          desc = '[J]upyter [R]estart kernel' },
      { '<leader>jv', ':<C-u>MoltenEvaluateVisual<cr>gv', mode = 'v', desc = '[J]upyter run selection' },
    },
    config = function()
      -- <leader>jc runs the markdown fenced block the cursor is inside — the
      -- "run this cell" action. Treesitter gives us the block's exact range.
      vim.keymap.set('n', '<leader>jc', function()
        local node = vim.treesitter.get_node()
        while node and node:type() ~= 'fenced_code_block' do
          node = node:parent()
        end
        if not node then
          vim.notify('Not inside a code cell', vim.log.levels.WARN)
          return
        end
        local srow, _, erow, _ = node:range()
        -- skip the ``` fence lines themselves
        vim.cmd(string.format('%d,%dMoltenEvaluateRange', srow + 2, erow))
      end, { desc = '[J]upyter run [c]ell', silent = true })

      -- Status in the statusline comes free via lualine's diagnostics; nothing to do.
    end,
  },
}
