local function my_on_attach(bufnr)
  local api = require 'nvim-tree.api'

  local function opts(desc)
    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- 1. Apply default mappings first
  api.map.on_attach.default(bufnr)

  -- 2. Custom Mappings
  -- Remove the default C-v mapping if it's interfering
  vim.keymap.del('n', '<C-v>', { buffer = bufnr })

  -- Map 'V' to Vertical Split instead
  vim.keymap.set('n', 'V', api.node.open.vertical, opts 'Open: Vertical Split')

  -- Map 'L' to change the root to the current node (Opposite of '-')
  vim.keymap.set('n', '_', api.tree.change_root_to_node, opts 'CD')

  -- vim.keymap.set('n', '<leader>t', api.tree.toggle, { desc = 'nvim-tree: Toggle' })
end

require('which-key').add { '<leader>tt', '<cmd>NvimTreeToggle<CR>', desc = 'nvim-tree: Toggle' }

local function open_win_config_func()
  local scr_w = vim.opt.columns:get()
  local scr_h = vim.opt.lines:get()
  local tree_w = 80
  local tree_h = math.floor(tree_w * scr_h / scr_w)
  return {
    border = 'double',
    relative = 'editor',
    width = tree_w,
    height = tree_h,
    col = (scr_w - tree_w) / 2,
    row = (scr_h - tree_h) / 2,
  }
end

return {

  {
    'nvim-tree/nvim-tree.lua',
    version = '*',
    lazy = false,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      -- require('nvim-tree').setup {
      --   on_attach = my_on_attach,
      --   renderer = {
      --     group_empty = true,
      --     icons = {
      --       show = {
      --         modified = true, -- Enable the icon
      --       },
      --       glyphs = {
      --         modified = '●', -- The "little dot" (use any NerdFont icon here)
      --       },
      --     },
      --   },
      -- }

      require('nvim-tree').setup {
        on_attach = my_on_attach,
        view = {
          signcolumn = 'no',
          float = {
            enable = false,
            open_win_config = open_win_config_func,
          },
          cursorline = true,
          number = true,
          cursorlineopt = 'number',
        },

        sort = {
          sorter = function(nodes)
            table.sort(nodes, function(a, b)
              -- 1. Get extensions (use empty string for folders/no extension)
              local ext_a = a.extension or ''
              local ext_b = b.extension or ''

              -- 2. If extensions are different, sort alphabetically by extension
              if ext_a ~= ext_b then
                return ext_a < ext_b
              end

              -- 3. If extensions are the same, sort alphabetically by name
              -- (This handles 'index.js' vs 'main.js')
              return a.name < b.name
            end)
          end,
        },

        modified = {
          enable = true,
          show_on_open_dirs = false,
        },

        diagnostics = {
          enable = false,
          show_on_dirs = true,
          show_on_open_dirs = false,
        },

        git = {
          enable = true,
          show_on_dirs = true,
          show_on_open_dirs = false,
        },

        renderer = {
          root_folder_label = function(path)
            return ' ' .. vim.fn.fnamemodify(path, ':t'):upper()
          end,
          special_files = { 'Cargo.toml', 'Makefile', 'README.md', 'readme.md', '.nvim.lua' },
          hidden_display = 'all',
          highlight_git = 'name',
          highlight_diagnostics = 'name',
          highlight_modified = 'icon',
          highlight_hidden = 'all',
          indent_markers = {
            enable = true,
            inline_arrows = false,
            icons = {
              item = '├',
            },
          },
          icons = {
            show = {
              hidden = false,
              folder_arrow = false,
              diagnostics = false,
            },
            git_placement = 'after',
            bookmarks_placement = 'after',
            symlink_arrow = ' -> ',
            glyphs = {
              folder = {
                -- arrow_closed = '',
                -- arrow_open = ' ',
                -- default = '',
                open = '󱧨',
                -- empty = '',
                empty_open = '󱧩',
                symlink = '',
                symlink_open = '',
              },
              default = '󱓻',
              symlink = '󱓻',
              bookmark = '',
              modified = '',
              hidden = '󱙝',
              git = {
                unstaged = '',
                staged = '',
                unmerged = '󰧾',
                untracked = '󰓹',
                renamed = '',
                deleted = '',
                ignored = '∅',
              },
            },
          },
        },
        filters = {
          -- git_ignored = false,
        },
        hijack_cursor = true,
        sync_root_with_cwd = true,
      }
    end,
  },

  -- {
  --   'nvim-neo-tree/neo-tree.nvim',
  --   branch = 'v3.x',
  --   dependencies = {
  --     'nvim-lua/plenary.nvim',
  --     'MunifTanjim/nui.nvim',
  --     'nvim-tree/nvim-web-devicons', -- optional, but recommended
  --   },
  --   lazy = false, -- neo-tree will lazily load itself
  -- },
}
