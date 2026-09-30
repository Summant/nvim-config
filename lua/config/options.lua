local o = vim.o
local opt = vim.opt

o.number = true
o.relativenumber = false
o.mouse = 'a'
o.showmode = false -- mini.statusline shows the mode

-- sync with system clipboard (scheduled so startup isn't slowed by the clipboard provider)
vim.schedule(function()
  o.clipboard = 'unnamedplus'
end)

-- indentation: 4 spaces (guess-indent overrides per file when it can detect it)
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
o.breakindent = true

o.undofile = true
o.ignorecase = true
o.smartcase = true
o.signcolumn = 'yes'
o.updatetime = 250
o.timeoutlen = 300
o.splitright = true
o.splitbelow = true
o.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
o.inccommand = 'split'
o.cursorline = true
o.scrolloff = 10
o.confirm = true
o.termguicolors = true
o.background = 'dark'
o.winborder = 'rounded' -- nvim 0.11+: rounded borders for all floating windows (hover, diagnostics, ...)
