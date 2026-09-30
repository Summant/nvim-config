-- Debugging (C/C++ via lldb-dap, from the `lldb` package). F5 run/continue, F10 over, F11 into, F12 out.
return {
  'rcarriga/nvim-dap-ui',
  dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' },
  keys = {
    { '<F5>', function() require('dap').continue() end, desc = 'Debug: Start/Continue' },
    { '<F10>', function() require('dap').step_over() end, desc = 'Debug: Step Over' },
    { '<F11>', function() require('dap').step_into() end, desc = 'Debug: Step Into' },
    { '<F12>', function() require('dap').step_out() end, desc = 'Debug: Step Out' },
    { '<leader>b', function() require('dap').toggle_breakpoint() end, desc = 'Debug: Toggle [B]reakpoint' },
    { '<leader>B', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, desc = 'Debug: Conditional [B]reakpoint' },
    { '<leader>dr', function() require('dap').repl.open() end, desc = '[D]ebug: [R]EPL' },
    { '<leader>dl', function() require('dap').run_last() end, desc = '[D]ebug: run [L]ast' },
    { '<leader>du', function() require('dapui').toggle() end, desc = '[D]ebug: toggle [U]I' },
  },
  config = function()
    local dap, dapui = require 'dap', require 'dapui'

    dap.adapters.lldb = { type = 'executable', command = 'lldb-dap', name = 'lldb' }
    dap.configurations.cpp = {
      {
        name = 'Launch C++ file',
        type = 'lldb',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = {},
      },
    }
    dap.configurations.c = dap.configurations.cpp

    dapui.setup()
    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close
  end,
}
