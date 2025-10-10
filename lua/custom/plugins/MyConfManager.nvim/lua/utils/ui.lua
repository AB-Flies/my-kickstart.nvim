M = {}

---@param path Path
local function to_string(path)
  local preffix = ''

  if path.is_tree then
    preffix = '(tree) '
  end

  return preffix .. path.path
end

---@param items Path[]
local function find_max_width(items)
  local max = 0

  for _, item in ipairs(items) do
    if #to_string(item) > max then
      max = #to_string(item)
    end
  end

  return max
end

---@param items Path[]
local function filter_paths(items)
  local arr = {}

  for i = 1, #items do
    table.insert(arr, to_string(items[i]))
  end

  return arr
end

---@param items Path[]
local function format_items(items, height)
  items = filter_paths(items)

  for _ = 1, height - #items do
    table.insert(items, 1, ' ')
  end

  return items
end

---@param items Path[]
function M.open_list(items)
  local buf = vim.api.nvim_create_buf(false, true)
  local title = 'd: delete   |   t: toggle tree   |   s: save and quit   |   q: quit'
  local width = math.max(find_max_width(items) + 8, #title + 8)
  local height = #items + 2

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, format_items(items, height))

  local function refresh()
    vim.api.nvim_set_option_value('modifiable', true, { buf = buf })
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, format_items(items, height))
    vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
  end

  -- Mark as special buffer (no file, no editing)
  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = buf })
  vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = buf })
  vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
  vim.api.nvim_set_option_value('filetype', 'MyList', { buf = buf })

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = 'minimal',
    border = 'rounded',
    title = title,
    title_pos = 'center',
  })

  -- Keymaps
  local function close_win()
    vim.api.nvim_win_close(win, true)
  end

  vim.keymap.set('n', '<C-k>', '<Nop>', { buffer = buf })
  vim.keymap.set('n', '<C-h>', '<Nop>', { buffer = buf })
  vim.keymap.set('n', '<C-l>', '<Nop>', { buffer = buf })
  vim.keymap.set('n', '<C-j>', '<Nop>', { buffer = buf })
  vim.keymap.set('n', '<C-w>', '<Nop>', { buffer = buf })
  vim.keymap.set('n', '<C-w>h', '<Nop>', { buffer = buf })
  vim.keymap.set('n', '<C-w>j', '<Nop>', { buffer = buf })
  vim.keymap.set('n', '<C-w>k', '<Nop>', { buffer = buf })
  vim.keymap.set('n', '<C-w>l', '<Nop>', { buffer = buf })
  vim.keymap.set('n', '<CR>', '<Nop>', { buffer = buf })
  vim.keymap.set('n', 'q', close_win, { buffer = buf, nowait = true })
  vim.keymap.set('n', 'd', function()
    if #items == 0 then
      return
    end

    local i = vim.api.nvim_win_get_cursor(0)[1]
    i = i - (height - #items)
    table.remove(items, i)
    refresh()
  end, { buffer = buf, nowait = true })
  vim.keymap.set('n', 't', function()
    if #items == 0 then
      return
    end

    local i = vim.api.nvim_win_get_cursor(0)[1]
    i = i - (height - #items)
    items[i].is_tree = not items[i].is_tree
    refresh()
  end, { buffer = buf, nowait = true })
  vim.keymap.set('n', 's', function()
    local fs = require 'utils.fs'
    fs.writeData(items)
    close_win()
  end, { buffer = buf, nowait = true })
  vim.api.nvim_create_autocmd('CursorMoved', {
    buffer = buf,
    callback = function()
      if #items == 0 then
        return
      end

      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      local padding = height - #items

      if row <= padding then
        vim.api.nvim_win_set_cursor(0, { padding + 1, col })
      elseif row > padding + #items then
        vim.api.nvim_win_set_cursor(0, { padding + #items, col })
      end
    end,
  })
end

return M
