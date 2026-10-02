-- Autocompletion. The popup appears as you type; Tab accepts, Tab/Shift-Tab cycle,
-- and the docs pane opens beside it automatically.
return {
  'saghen/blink.cmp',
  event = 'VimEnter',
  version = '1.*',
  dependencies = {
    {
      'L3MON4D3/LuaSnip',
      version = '2.*',
      build = (vim.fn.executable 'make' == 1) and 'make install_jsregexp' or nil,
      opts = {},
    },
    'folke/lazydev.nvim',
    'rafamadriz/friendly-snippets', -- a large community snippet collection
  },
  opts = {
    keymap = {
      preset = 'super-tab',             -- Tab accepts / cycles, like VS Code
      ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<C-e>']     = { 'hide' },
      ['<C-j>']     = { 'select_next', 'fallback' },
      ['<C-k>']     = { 'select_prev', 'fallback' },
    },
    appearance = { nerd_font_variant = 'mono' },
    completion = {
      -- show the popup after a short pause, with the docs pane beside it
      trigger = { show_on_trigger_character = true },
      menu = {
        border = 'rounded',
        winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None',
        draw = {
          treesitter = { 'lsp' },       -- syntax-highlight the suggestions
          columns = {
            { 'kind_icon' },
            { 'label', 'label_description', gap = 1 },
            { 'kind', gap = 1 },
          },
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 150,
        window = {
          border = 'rounded',
          winhighlight = 'Normal:Normal,FloatBorder:FloatBorder',
        },
      },
      ghost_text = { enabled = true },  -- inline preview of the top suggestion
      list = { selection = { preselect = true, auto_insert = false } },
    },
    signature = {
      enabled = true,
      window = { border = 'rounded' },
    },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'lazydev' },
      providers = {
        lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
      },
    },
    snippets = { preset = 'luasnip' },
    fuzzy = { implementation = 'prefer_rust_with_warning' },
  },
}
