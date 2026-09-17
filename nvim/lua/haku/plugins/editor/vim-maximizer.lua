local api = vim.api
local states = {}
local covers = {}
local cover_buf
local signature
local pending = false
local navigating = false

local function windows()
  return vim.tbl_filter(function(win)
    return api.nvim_win_get_config(win).relative == ""
  end, api.nvim_tabpage_list_wins(0))
end

local function clear_covers()
  for _, win in ipairs(covers) do
    if api.nvim_win_is_valid(win) then
      vim.cmd("noautocmd call nvim_win_close(" .. win .. ", v:true)")
    end
  end
  covers = {}
  signature = nil
end

local function state()
  return states[api.nvim_get_current_tabpage()]
end

local function refresh(panel_sizes)
  local s = state()
  if not s then
    clear_covers()
    return
  end

  local original = {}
  for _, saved in ipairs(s.original) do
    original[saved.win] = true
  end
  local tools = {}
  for _, win in ipairs(windows()) do
    if not original[win] then
      tools[#tools + 1] = (panel_sizes and panel_sizes[win])
        or { win = win, width = api.nvim_win_get_width(win), height = api.nvim_win_get_height(win) }
    end
  end

  -- Only the windows collapsed when zoom began are kept small.
  -- Newly opened chat/terminal windows retain their own dimensions.
  for win, small in pairs(s.hidden) do
    if api.nvim_win_is_valid(win) then
      if small.width and api.nvim_win_get_width(win) ~= small.width then
        pcall(api.nvim_win_set_width, win, small.width)
      end
      if small.height and api.nvim_win_get_height(win) ~= small.height then
        pcall(api.nvim_win_set_height, win, small.height)
      end
    end
  end

  -- Shrinking an old editor can give space to its new neighbor.
  -- Put tool panels back at their plugin-selected sizes.
  local fixed = {}
  for win in pairs(s.hidden) do
    if api.nvim_win_is_valid(win) then
      fixed[win] = { vim.wo[win].winfixwidth, vim.wo[win].winfixheight }
      vim.wo[win].winfixwidth = true
      vim.wo[win].winfixheight = true
    end
  end
  for _, tool in ipairs(tools) do
    pcall(api.nvim_win_set_width, tool.win, tool.width)
    pcall(api.nvim_win_set_height, tool.win, tool.height)
  end

  for win, opts in pairs(fixed) do
    vim.wo[win].winfixwidth = opts[1]
    vim.wo[win].winfixheight = opts[2]
  end

  s.panel_sizes = {}
  for _, tool in ipairs(tools) do
    s.panel_sizes[tool.win] = tool
  end

  local rectangles = {}
  for win in pairs(s.hidden) do
    if api.nvim_win_is_valid(win) then
      local pos = api.nvim_win_get_position(win)
      rectangles[#rectangles + 1] = {
        win = win,
        row = pos[1],
        col = pos[2],
        width = api.nvim_win_get_width(win),
        -- height = api.nvim_win_get_height(win) + ((vim.o.laststatus == 1 or vim.o.laststatus == 2) and 1 or 0),
        height = api.nvim_win_get_height(win),
      }
    end
  end
  table.sort(rectangles, function(a, b)
    return a.win < b.win
  end)
  local next_signature = vim.inspect(rectangles)
  if signature == next_signature then
    return
  end
  clear_covers()

  if not cover_buf or not api.nvim_buf_is_valid(cover_buf) then
    cover_buf = api.nvim_create_buf(false, true)
  end
  for _, rect in ipairs(rectangles) do
    local win = api.nvim_open_win(cover_buf, false, {
      relative = "editor",
      row = rect.row,
      col = rect.col,
      width = rect.width,
      height = rect.height,
      style = "minimal",
      focusable = false,
      mouse = false,
      zindex = 40,
      noautocmd = true,
    })
    vim.wo[win].winhighlight = "Normal:MaximizedStrip,NormalNC:MaximizedStrip,EndOfBuffer:MaximizedStrip"
    vim.wo[win].fillchars = "eob: "
    covers[#covers + 1] = win
  end
  signature = next_signature
end

local function queue_refresh()
  if pending then
    return
  end
  pending = true
  vim.schedule(function()
    pending = false
    refresh()
  end)
end

local function restore()
  local s = state()
  clear_covers()
  if not s then
    return
  end
  states[api.nvim_get_current_tabpage()] = nil
  vim.t.maximizer_sizes = nil

  -- Restore by window ID: opening panels changes window numbers.
  -- Scale original editors into the space they currently occupy.
  -- for _, dimension in ipairs({ "width", "height" }) do
  --   local get = api["nvim_win_get_" .. dimension]
  --   local set = api["nvim_win_set_" .. dimension]
  --   local before, now = 0, 0
  --   for _, saved in ipairs(s.original) do
  --     if api.nvim_win_is_valid(saved.win) then
  --       before = before + saved[dimension]
  --       now = now + get(saved.win)
  --     end
  --   end
  --   if before > 0 then
  --     for _, saved in ipairs(s.original) do
  --       if api.nvim_win_is_valid(saved.win) then
  --         pcall(set, saved.win, math.max(1, math.floor(saved[dimension] * now / before + 0.5)))
  --       end
  --     end
  --   end
  -- end

  if s.restore_cmd then
    vim.cmd(s.restore_cmd)
  end
  if api.nvim_win_is_valid(s.focus) then
    api.nvim_set_current_win(s.focus)
  end
end

local function hide_tool_panels(editor)
  local tab = api.nvim_get_current_tabpage()
  local terminal = package.loaded["toggleterm.terminal"]
  if terminal then
    for _, term in pairs(terminal.get_all(true)) do
      local win = term.window
      if win and api.nvim_win_is_valid(win) and win ~= editor and api.nvim_win_get_tabpage(win) == tab then
        term:close() -- Hide the terminal; keep its process and buffer.
      end
    end
  end

  local Chat = package.loaded["codecompanion.interactions.chat"]
  if Chat then
    for _, win in ipairs(api.nvim_tabpage_list_wins(tab)) do
      local buf = api.nvim_win_get_buf(win)
      if win ~= editor and vim.bo[buf].filetype == "codecompanion" then
        local chat = Chat.buf_get_chat(buf)
        if chat and chat.ui then
          chat.ui:hide() -- Keep the conversation available for reopening.
        end
      end
    end
  end
  api.nvim_set_current_win(editor)
end

local function maximize()
  local current = api.nvim_get_current_win()
  if api.nvim_win_get_config(current).relative ~= "" then
    return
  end
  -- local buf = api.nvim_win_get_buf(current)
  -- if vim.bo[buf].buftype == "" and vim.bo[buf].filetype ~= "codecompanion" then
  --   hide_tool_panels(current)
  -- end
  local wins = windows()
  clear_covers()
  -- local s = { original = {}, hidden = {}, focus = current }
  local s = {
    original = {},
    hidden = {},
    focus = current,
    restore_cmd = vim.fn.winrestcmd(),
  }
  for _, win in ipairs(wins) do
    s.original[#s.original + 1] = {
      win = win,
      width = api.nvim_win_get_width(win),
      height = api.nvim_win_get_height(win),
    }
  end
  vim.cmd("MaximizerToggle!")
  for _, saved in ipairs(s.original) do
    if saved.win ~= current then
      local width = api.nvim_win_get_width(saved.win)
      local height = api.nvim_win_get_height(saved.win)
      s.hidden[saved.win] = {
        width = width < saved.width and width or nil,
        height = height < saved.height and height or nil,
      }
    end
  end
  states[api.nvim_get_current_tabpage()] = s
  refresh()
end

local function toggle()
  if state() then
    restore()
  else
    maximize()
  end
end

local function navigate(command)
  local s = state()
  if not s then
    vim.cmd(command)
    return
  end

  -- Keep the existing zoom session: do not capture tool panels as editors.
  local original = {}
  for _, saved in ipairs(s.original) do
    original[saved.win] = true
  end
  local panel_sizes = {}
  for _, win in ipairs(windows()) do
    if not original[win] then
      panel_sizes[win] = {
        win = win,
        width = api.nvim_win_get_width(win),
        height = api.nvim_win_get_height(win),
      }
    end
  end

  local target
  if next(panel_sizes) then
    -- With tool panels open, navigate only among visible windows.
    local current = api.nvim_get_current_win()
    local pos = api.nvim_win_get_position(current)
    local right = command == "TmuxNavigateRight"
    local best
    for _, win in ipairs(windows()) do
      if win ~= current and not s.hidden[win] then
        local p = api.nvim_win_get_position(win)
        local dx = p[2] - pos[2]
        local overlap = math.min(pos[1] + api.nvim_win_get_height(current), p[1] + api.nvim_win_get_height(win))
          - math.max(pos[1], p[1])
        if overlap > 0 and ((right and dx > 0) or (not right and dx < 0)) then
          local distance = math.abs(dx)
          if not best or distance < best then
            target, best = win, distance
          end
        end
      end
    end
    -- if not target then
    --   return
    -- end
  end

  clear_covers()
  navigating = true
  local ok, err = pcall(function()
    if target then
      api.nvim_set_current_win(target)
    else
      vim.cmd(command)
    end
  end)
  navigating = false

  if state() == s then
    local destination = api.nvim_get_current_win()
    local small = s.hidden[destination]
    if small then
      s.hidden[destination] = nil
      if api.nvim_win_is_valid(s.focus) then
        s.hidden[s.focus] = small
      end
      s.focus = destination
    end
    refresh(panel_sizes)
  else
    queue_refresh()
  end

  if not ok then
    error(err)
  end
end

return {
  "szw/vim-maximizer",
  init = function()
    vim.g.maximizer_restore_on_winleave = 0
    vim.g.maximizer_set_default_mapping = 0
    vim.o.winminwidth = 1
    vim.o.winminheight = 1
  end,
  config = function()
    local group = api.nvim_create_augroup("MaximizerStrip", { clear = true })
    local function color()
      api.nvim_set_hl(0, "MaximizedStrip", {
        bg = "#565f89", -- Change the strip color here
        -- bg = "#734F96",
        -- bg = "#3551a9",
      })
    end
    color()
    api.nvim_create_autocmd("ColorScheme", { group = group, callback = color })
    api.nvim_create_autocmd({
      "WinNew",
      "WinClosed",
      "WinResized",
      "VimResized",
      "BufWinEnter",
      "WinEnter",
      "TabEnter",
    }, { group = group, callback = queue_refresh })
    api.nvim_create_autocmd("TabLeave", { group = group, callback = clear_covers })
    -- A closing tool can return focus to a collapsed editor.
    -- Redirect to the visible editor without ending the zoom session.
    api.nvim_create_autocmd("WinEnter", {
      group = group,
      callback = function()
        local s = state()
        if not navigating and s and s.hidden[api.nvim_get_current_win()] then
          local panel_sizes = s.panel_sizes
          vim.schedule(function()
            if state() == s and s.hidden[api.nvim_get_current_win()] and api.nvim_win_is_valid(s.focus) then
              api.nvim_set_current_win(s.focus)
              refresh(panel_sizes)
            end
          end)
        end
      end,
    })
  end,
  keys = {
    { "<leader>sm", toggle, desc = "Maximize/minimize a split" },
    {
      "<C-h>",
      function()
        navigate("TmuxNavigateLeft")
      end,
      desc = "Navigate left, keeping maximization",
    },
    {
      "<C-l>",
      function()
        navigate("TmuxNavigateRight")
      end,
      desc = "Navigate right, keeping maximization",
    },
  },
}
