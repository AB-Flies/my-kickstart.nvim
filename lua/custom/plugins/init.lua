local function relpath(path)
  return vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h') .. '/' .. path
end

-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

vim.opt.guicursor = {
  'n-v-c:block', -- Normal, Visual, Command-line: block cursor
  'i-ci-ve:ver25', -- Insert and related modes: vertical bar
  'r-cr:hor20', -- Replace modes: horizontal underline
  'o:hor50', -- Operator-pending: thick underline
  'sm:block-blinkwait175-blinkoff150-blinkon175',
}

-- When focus is regained, force Neovim to resend the cursor shape
vim.api.nvim_create_autocmd('FocusGained', {
  callback = function()
    local mode = vim.fn.mode()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Cmd>redraw!<CR>', true, false, true), 'n', true)
    -- Optional: re-send current mode explicitly
    if mode == 'i' then
      vim.cmd 'set guicursor+=i-ci-ve:ver25'
    elseif mode == 'n' then
      vim.cmd 'set guicursor+=n-v-c:block'
    end
  end,
})

return {
  { 'tpope/vim-fugitive' },
  'mg979/vim-visual-multi',

  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        clangd = {
          cmd = {
            'clangd',
            '--std=c++23',
          },
        },
      },
    },
  },

  {
    'iamcco/markdown-preview.nvim',
    build = 'cd app && npm install',
    ft = { 'markdown' },
    init = function()
      vim.g.mkdp_auto_start = 0 -- set to 1 if you want auto preview
    end,
  },

  {
    dir = relpath 'MyConfManager.nvim/',
    init = function()
      require('MyConfManager').setup {}
    end,
  },

  {
    'kevinhwang91/nvim-ufo',
    dependencies = 'kevinhwang91/promise-async',
  },

  {
    'rcarriga/nvim-notify',
    config = function()
      vim.notify = require 'notify'
    end,
  },
}
