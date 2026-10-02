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

  { -- run cells against a Jupyter kernel
    'benlubas/molten-nvim',
    version = '^1.0.0',
    dependencies = { '3rd/image.nvim' },
    build = ':UpdateRemotePlugins',
    ft = { 'python', 'markdown', 'quarto' },
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
