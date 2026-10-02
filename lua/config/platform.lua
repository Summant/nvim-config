-- Small helpers so this config works unchanged on Linux and macOS.
local M = {}

M.is_mac   = vim.uv.os_uname().sysname == 'Darwin'
M.is_linux = vim.uv.os_uname().sysname == 'Linux'

--- First executable found in `names`, or nil.
function M.first_exe(names)
  for _, n in ipairs(names) do
    if vim.fn.executable(n) == 1 then
      return n
    end
  end
  return nil
end

--- Resolve lldb-dap, which is packaged differently per platform:
---   Linux  — `lldb-dap` on PATH (Arch's `lldb` package)
---   macOS  — inside the Xcode/CLT toolchain, found via `xcrun -f`
--- Falls back to mason's codelldb if neither is present.
function M.lldb_dap()
  local exe = M.first_exe { 'lldb-dap', 'lldb-vscode' }
  if exe then
    return exe
  end
  if M.is_mac and vim.fn.executable 'xcrun' == 1 then
    local out = vim.fn.system { 'xcrun', '-f', 'lldb-dap' }
    out = vim.trim(out)
    if vim.v.shell_error == 0 and out ~= '' and vim.fn.executable(out) == 1 then
      return out
    end
  end
  local mason = vim.fn.stdpath 'data' .. '/mason/bin/codelldb'
  if vim.fn.executable(mason) == 1 then
    return mason
  end
  return nil
end

--- Clipboard works out of the box on both (wl-copy / pbcopy are auto-detected
--- by Neovim), so nothing to configure — documented here so it isn't "fixed".
return M
