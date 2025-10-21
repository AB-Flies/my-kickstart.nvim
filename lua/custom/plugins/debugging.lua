return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'rcarriga/nvim-dap-ui',
    'mfussenegger/nvim-dap-python',
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('dapui').setup()
    require('dap-python').setup 'python3'

    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end

    vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Continue' })
    vim.keymap.set('n', '<F6>', dap.restart, { desc = 'Restart' })
    vim.keymap.set('n', '<F8>', dap.step_over, { desc = 'Step over' })
    vim.keymap.set('n', '<F7>', dap.step_into, { desc = 'Step into' })
    vim.keymap.set('n', '<F10>', dap.step_out, { desc = 'Step out' })
    vim.keymap.set('n', '<F9>', dap.toggle_breakpoint, { desc = 'Toggle breakpoint' })

    local wk = require 'which-key'
    wk.add { { '<leader>d', group = 'Debugging' } }
    vim.keymap.set('n', '<Leader>dc', dap.continue, { desc = 'Continue' })
    vim.keymap.set('n', '<Leader>ds', dap.step_over, { desc = 'Step over' })
    vim.keymap.set('n', '<Leader>di', dap.step_into, { desc = 'Step into' })
    vim.keymap.set('n', '<Leader>do', dap.step_out, { desc = 'Step out' })
    vim.keymap.set('n', '<Leader>dr', dap.restart, { desc = 'Restart' })
    vim.keymap.set('n', '<Leader>db', dap.toggle_breakpoint, { desc = 'Toggle breakpoint' })
  end,
}
