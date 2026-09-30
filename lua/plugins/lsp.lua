-- LSP via the native Neovim 0.11+ API (vim.lsp.config / vim.lsp.enable). nvim-lspconfig only supplies
-- the per-server defaults; mason installs the servers; mason-lspconfig enables whatever is installed.
return {
  { 'folke/lazydev.nvim', ft = 'lua', opts = { library = { { path = '${3rd}/luv/library', words = { 'vim%.uv' } } } } },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'saghen/blink.cmp',
    },
    config = function()
      -- keymaps + per-buffer features when a server attaches
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            vim.keymap.set(mode or 'n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          local tb = require 'telescope.builtin'
          -- gd / gD go straight to definition / declaration (your fix)
          map('gd', tb.lsp_definitions, '[G]oto [D]efinition')
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
          map('grr', tb.lsp_references, '[G]oto [R]eferences')
          map('gri', tb.lsp_implementations, '[G]oto [I]mplementation')
          map('grd', tb.lsp_definitions, '[G]oto [D]efinition')
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('grt', tb.lsp_type_definitions, '[G]oto [T]ype Definition')
          map('gO', tb.lsp_document_symbols, 'Open Document Symbols')
          map('gW', tb.lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
          map('K', vim.lsp.buf.hover, 'Hover documentation')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if not client then return end

          -- highlight other references of the word under the cursor
          if client:supports_method('textDocument/documentHighlight', event.buf) then
            local grp = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, { buffer = event.buf, group = grp, callback = vim.lsp.buf.document_highlight })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, { buffer = event.buf, group = grp, callback = vim.lsp.buf.clear_references })
            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
              callback = function(ev)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = ev.buf }
              end,
            })
          end

          if client:supports_method('textDocument/inlayHint', event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      vim.diagnostic.config {
        severity_sort = true,
        float = { source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = { source = 'if_many', spacing = 2 },
      }

      -- capabilities from blink.cmp apply to every server
      vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities() })

      -- servers + their settings. Add more here; mason installs them on next :MasonToolsInstall / startup.
      local servers = {
        lua_ls = { settings = { Lua = { completion = { callSnippet = 'Replace' } } } },
        clangd = { cmd = { 'clangd', '--background-index', '--clang-tidy', '--header-insertion=iwyu' } }, -- system clangd
        basedpyright = {},
        bashls = {},
        jsonls = {},
      }
      for name, cfg in pairs(servers) do
        vim.lsp.config(name, cfg)
      end

      -- tools mason should install (clangd comes from the system package, so it's excluded)
      local ensure = vim.tbl_filter(function(n) return n ~= 'clangd' end, vim.tbl_keys(servers))
      vim.list_extend(ensure, { 'stylua', 'clang-format', 'ruff' })
      require('mason-tool-installer').setup { ensure_installed = ensure }

      require('mason-lspconfig').setup {
        ensure_installed = {},
        automatic_enable = true, -- vim.lsp.enable() for every mason-installed server
      }
      vim.lsp.enable 'clangd' -- not mason-managed, enable explicitly
    end,
  },
}
