local M = {}

M.dirName = vim.fn.stdpath 'data' .. '/MyConfManager'
M.fileName = M.dirName .. '/trusted.json'

function M.ensureDir()
  if vim.fn.isdirectory(M.dirName) == 0 then
    vim.fn.mkdir(M.dirName)
    print(('Created dir %s'):format(M.dirName))
  end
end

function M.loadData()
  local file, err = io.open(M.fileName, 'r+')
  local empty = {}

  if not file then
    file, err = io.open(M.fileName, 'w+')

    if not file then
      vim.notify(('loadData: could not open or create %s: %s'):format(M.fileName, err), vim.log.levels.ERROR)
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
    vim.notify(('Reader: invalid JSON in %s: %s'):format(M.fileName, parsed), vim.log.levels.WARN)
    return empty
  end

  return parsed
end

function M.writeData(obj)
  local ok, content = pcall(vim.fn.json_encode, obj)
  if not ok then
    vim.notify('writeData: could not encode the table. data has not been saved.', vim.log.levels.ERROR)
  end

  local file, err = io.open(M.fileName, 'w+')

  if not file then
    vim.notify(('writeData: could not open or create %s: %s. Please check backup: %s'):format(M.fileName, err, M.fileName .. '.backup'), vim.log.levels.ERROR)
    return false
  else
    file:write(content)
    file:flush()
    file:close()
  end

  local backup, b_err = io.open(M.fileName .. '.backup', 'w+')
  if not backup then
    vim.notify(('writeData: could not open or create %s: %s. Backup could not be saved'):format(M.fileName .. '.backup', b_err), vim.log.levels.WARN)
    return false
  end

  return true
end

return M
