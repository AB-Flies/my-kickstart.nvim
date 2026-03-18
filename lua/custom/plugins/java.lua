return {
  { 'mfussenegger/nvim-jdtls' },

  -- {
  --   'nvim-java/nvim-java',
  --   config = function()
  --     require('java').setup()
  --     vim.lsp.config('jdtls', {
  --       cmd = { 'jdtls' },
  --     })
  --   end,
  -- },

  {
    'AB-Flies/maven.nvim',
    -- dir = '~/maven.nvim',
    cmd = { 'Maven', 'MavenExec' },
    dependencies = 'nvim-lua/plenary.nvim',
    config = function()
      require('maven').setup {
        executable = 'mvn',
      }
    end,
  },
}
