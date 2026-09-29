-- Neovim config — modernized from github.com/Summant/nvim-config (kickstart-based) for Neovim 0.12
-- Layout:
--   lua/config/options.lua   editor options
--   lua/config/keymaps.lua   non-plugin keymaps
--   lua/config/autocmds.lua  autocommands
--   lua/config/lazy.lua      plugin manager bootstrap
--   lua/plugins/*.lua        one file per plugin group (auto-loaded)
--   lua/custom/plugins/      drop extra plugin specs here

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true -- JetBrainsMono Nerd Font is installed

require 'config.options'
require 'config.keymaps'
require 'config.autocmds'
require 'config.lazy'
