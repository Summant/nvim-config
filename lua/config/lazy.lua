local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', 'https://github.com/folke/lazy.nvim.git', lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  { import = 'plugins' },
  { import = 'custom.plugins' },
}, {
  checker = { enabled = true, notify = false }, -- check for plugin updates quietly; :Lazy to review
  change_detection = { notify = false },
  ui = { border = 'rounded' },
  rocks = { enabled = false }, -- nothing here needs luarocks; skips the hererocks health warning
})
