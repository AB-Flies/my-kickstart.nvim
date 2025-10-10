local M = {}

---@class Path
---@field path string
---@field is_tree boolean

local fs = require 'utils.fs'
local name = '.nvim.lua'
local choices = {
  '1. Load and trust current directory tree',
  '2. Load and trust current directory',
  '3. Load',
  '4. Ignore',
}
local max_config_size = 5 * 1024 -- Around > 1.250 lines
local autoload = true

---@param table Path[]
---@param value string The path to search
---@param cmp_fnc function receives a Path and a string, respectively
---@return integer|nil
local function find(table, value, cmp_fnc)
  cmp_fnc = cmp_fnc or function(a, b)
    return a == b
  end

  for i = 1, #table do
    if cmp_fnc(table[i], value) then
      return i
    end
  end

  return nil
end

local function load(path, stat)
  if stat.size > max_config_size then
    vim.ui.select({ 'continue', 'cancel' }, {
      prompt = ("The config file's size exceeds the limit (%sb): %sb. What to do?"):format(max_config_size, stat.size),
    }, function(choice)
      if choice == 'cancel' then
        return
      else
        dofile(path)
      end
    end)
  end
end

local function checkFile(force)
  if not autoload and not force then
    return
  end

  local path = vim.fn.getcwd() .. '/' .. name
  local stat = vim.uv.fs_stat(path)

  if stat == nil then
    return false
  else
    ---@type Path[]
    local data = fs.loadData()
    local i = find(data, vim.fn.getcwd(), function(_path, str)
      if _path.is_tree then
        return not (string.find(_path.path, str, 1, true) == nil)
      else
        return _path.path == str
      end
    end)

    if i ~= nil then
      load(path, stat)
    else
      -- The select starts with an 'A' pressed. This is to flush the buffer
      while vim.fn.getchar(0) ~= 0 do
      end
      vim.ui.select(choices, {
        prompt = 'A local config file has been found in the cwd. What should be done?',
      }, function(choice)
        if choice == choices[4] then
          return
        end

        load(path, stat)

        if choice == choices[1] then
          table.insert(data, { path = vim.fn.getcwd(), is_tree = true })
          fs.writeData(data)
        elseif choice == choices[2] then
          table.insert(data, { path = vim.fn.getcwd(), is_tree = false })
          fs.writeData(data)
        end
      end)
    end
  end

  return true
end

M.setup = function(opts)
  name = opts.name or name
  max_config_size = opts.max_config_size or max_config_size
  autoload = opts.autoload or autoload

  fs.ensureDir()
  vim.api.nvim_create_autocmd({ 'DirChanged', 'VimEnter' }, { callback = checkFile })
end

vim.api.nvim_create_user_command('MyConfManagerLoad', function()
  if not checkFile(true) then
    vim.notify 'Config file not found'
  end
end, {})

vim.api.nvim_create_user_command('MyConfManagerToggleAutoload', function()
  autoload = not autoload
  vim.notify(('Autoload set to %s'):format(autoload), vim.log.levels.INFO)
end, {})

vim.api.nvim_create_user_command('MyConfManagerTrustedList', function()
  local data = fs.loadData()
  require('utils.ui').open_list(data)
end, {})

return M
