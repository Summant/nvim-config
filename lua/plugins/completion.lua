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
  },
  opts = {
    keymap = { preset = 'super-tab' }, -- Tab accepts / cycles, like VS Code
    appearance = { nerd_font_variant = 'mono' },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 400 },
      ghost_text = { enabled = true },
    },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'lazydev' },
      providers = { lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 } },
    },
    snippets = { preset = 'luasnip' },
    fuzzy = { implementation = 'prefer_rust_with_warning' },
    signature = { enabled = true },
  },
}
