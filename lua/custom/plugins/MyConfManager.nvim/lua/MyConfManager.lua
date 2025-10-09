local M = {}

local dirName = vim.fn.stdpath 'data' .. '/MyConfManager'
local fileName = dirName .. '/trusted.json'

local function loadData()
  local file, err = io.open(fileName, 'r+')
  local empty = {}

  if not file then
    file, err = io.open(fileName, 'w+')

    if not file then
      vim.notify(('loadData: could not open or create %s: %s'):format(fileName, err), vim.log.levels.ERROR)
      return empty
    end
  end

  local content = file:read '*a'
  file:close()

  if not content or content == '' then
    return empty
  end

  local ok, parsed = pcall(vim.fn.json_decode, content)
  if not ok then
    vim.notify(('Reader: invalid JSON in %s: %s'):format(fileName, parsed), vim.log.levels.WARN)
    return empty
  end

  return parsed
end

local function writeData(obj)
  local ok, content = pcall(vim.fn.json_encode, obj)
  if not ok then
    vim.notify('writeData: could not encode the table. data has not been saved.', vim.log.levels.ERROR)
  end

  local file, err = io.open(fileName, 'w+')

  if not file then
    vim.notify(('writeData: could not open or create %s: %s. Please check backup: %s'):format(fileName, err, fileName .. '.backup'), vim.log.levels.ERROR)
    return false
  else
    file:write(content)
    file:flush()
    file:close()
  end

  local backup, b_err = io.open(fileName .. '.backup', 'w+')
  if not backup then
    vim.notify(('writeData: could not open or create %s: %s. Backup could not be saved'):format(fileName .. '.backup', b_err), vim.log.levels.WARN)
    return false
  end

  return true
end

M.setup = function()
  if vim.fn.isdirectory(dirName) == 0 then
    vim.fn.mkdir(dirName)
    print 'created dir'
  end

  writeData {}
end

return M
