local width_threshold = 0
local backdrop_win = nil
local backdrop_buf = nil

local function create_backdrop()
  -- Prevent spawning multiple backdrops
  if backdrop_win and vim.api.nvim_win_is_valid(backdrop_win) then
    return
  end

  -- Create a scratch buffer for the backdrop
  backdrop_buf = vim.api.nvim_create_buf(false, true)

  -- Get the current editor dimensions
  local width = vim.o.columns
  local height = vim.o.lines

  -- Open a full-screen floating window
  backdrop_win = vim.api.nvim_open_win(backdrop_buf, false, {
    relative = 'editor',
    width = width,
    height = height,
    row = 0,
    col = 0,
    style = 'minimal',
    focusable = false,
    zindex = 10, -- Keep it lower than Telescope (which defaults to 50+)
  })

  -- Set up the highlight and transparency
  vim.api.nvim_set_hl(0, 'TelescopeBackdrop', { bg = '#000000' })
  vim.wo[backdrop_win].winhighlight = 'Normal:TelescopeBackdrop'
  vim.wo[backdrop_win].winblend = 50 -- Transparency: 0 is solid, 100 is invisible
end

local function close_backdrop()
  -- Safely close the window and delete the buffer
  if backdrop_win and vim.api.nvim_win_is_valid(backdrop_win) then
    vim.api.nvim_win_close(backdrop_win, true)
    backdrop_win = nil
  end
  if backdrop_buf and vim.api.nvim_buf_is_valid(backdrop_buf) then
    vim.api.nvim_buf_delete(backdrop_buf, { force = true })
    backdrop_buf = nil
  end
end

-- Hook into Telescope's lifecycle
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'TelescopePrompt',
  callback = function(ctx)
    -- Get the window ID associated with the Telescope prompt buffer
    local prompt_win = vim.fn.bufwinid(ctx.buf)

    -- Safety fallback to the current window just in case bufwinid isn't ready
    if prompt_win == -1 then
      prompt_win = vim.api.nvim_get_current_win()
    end

    local win_width = vim.api.nvim_win_get_width(prompt_win)
    local editor_width = vim.o.columns

    -- Only apply the backdrop if the window is wider than 60% of the editor
    if win_width > (editor_width * width_threshold) then
      create_backdrop()

      -- When the Telescope prompt closes, wipe out the backdrop
      vim.api.nvim_create_autocmd('BufWipeout', {
        buffer = ctx.buf,
        callback = function()
          close_backdrop()
        end,
        once = true,
      })
    end
  end,
})

return {}
