local function relpath(path)
  return vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h') .. '/' .. path
end

-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  { 'catppuccin/nvim', name = 'catppuccin', priority = 1000 },
  {
    'iamcco/markdown-preview.nvim',
    build = 'cd app && npm install',
    ft = { 'markdown' },
    init = function()
      vim.g.mkdp_auto_start = 0 -- set to 1 if you want auto preview
    end,
  },
  {
    'nvim-tree/nvim-tree.lua',
    version = '*',
    lazy = false,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require('nvim-tree').setup {}
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
}

--
