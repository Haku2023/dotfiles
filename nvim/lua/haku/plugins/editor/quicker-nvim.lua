-- Open the quickfix/loclist entry under the cursor.
-- Reuses a real editing window when one exists; when only a special
-- window (e.g. the alpha greeter) is around, it replaces that window
-- instead of splitting off of it.
local function open_entry(action)
  local qf_win = vim.api.nvim_get_current_win()
  local lnum = vim.api.nvim_win_get_cursor(qf_win)[1]
  local info = vim.fn.getwininfo(qf_win)[1]
  local list = info.loclist == 1 and vim.fn.getloclist(qf_win) or vim.fn.getqflist()
  local item = list[lnum]
  if not item or not item.bufnr or item.bufnr == 0 then
    return
  end

  -- Find a usable "normal" window to land in (skip qf, floats, greeter).
  local file_win, any_win
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if win ~= qf_win and vim.api.nvim_win_get_config(win).relative == "" then
      any_win = any_win or win
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].buftype == "" and vim.bo[buf].filetype ~= "alpha" then
        file_win = win
        break
      end
    end
  end

  local fname = vim.fn.fnameescape(vim.api.nvim_buf_get_name(item.bufnr))

  if file_win then
    -- A real editing window exists: honour edit/split/vsplit there.
    vim.api.nvim_set_current_win(file_win)
    local cmd = action == "split" and "split" or action == "vsplit" and "vsplit" or "edit"
    vim.cmd(cmd .. " " .. fname)
  else
    -- Only the greeter (or similar) is around: replace it, never split.
    if any_win then
      vim.api.nvim_set_current_win(any_win)
    end
    vim.cmd("edit " .. fname)
  end

  vim.api.nvim_win_set_cursor(0, { item.lnum, math.max((item.col or 1) - 1, 0) })
end

return {
  "stevearc/quicker.nvim",
  -- ft = "qf",
  event = "VeryLazy",
  ---@module "quicker"
  ---@type quicker.SetupOptions
  opts = {
    opts = {
      buflisted = false,
      number = false,
      relativenumber = false,
      signcolumn = "auto",
      winfixheight = true,
      wrap = false,
    },
    max_filename_width = function()
      return math.floor(math.min(95, vim.o.columns / 2))
    end,
    -- Set height to half of editor height
    on_qf = function(bufnr)
      vim.cmd("resize " .. math.floor(vim.o.lines / 3))
    end,
    keys = {
      {
        ">",
        function()
          require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
        end,
        desc = "Expand quickfix context",
      },
      {
        "<",
        function()
          require("quicker").collapse()
        end,
        desc = "Collapse quickfix context",
      },
      {
        "<CR>",
        function()
          open_entry("edit")
        end,
        desc = "Open entry",
      },
      {
        "<C-s>",
        function()
          open_entry("split")
        end,
        desc = "Open entry in horizontal split",
      },
      {
        "<C-v>",
        function()
          open_entry("vsplit")
        end,
        desc = "Open entry in vertical split",
      },
    },
  },
  keys = {
    {
      "<leader>ql",
      function()
        require("quicker").toggle()
      end,
      desc = "Toggle quickfix",
    },
    {
      "<leader>qq",
      function()
        local bufnr = vim.api.nvim_get_current_buf()
        local lnum = vim.api.nvim_win_get_cursor(0)[1]
        local line = vim.api.nvim_get_current_line()

        vim.fn.setqflist({
          {
            bufnr = bufnr,
            lnum = lnum,
            col = 1,
            text = vim.trim(line),
          },
        }, "a") -- "a" appends to the existing quickfix list
      end,
      desc = "Add current line to quickfix",
      mode = "n",
    },
    {
      "<leader>ol",
      function()
        require("quicker").toggle({ loclist = true })
      end,
      desc = "Toggle loclist",
    },
    {
      "<leader>od",
      "<cmd>lua vim.diagnostic.setqflist()<CR>",
      desc = "Give workspace diagnostic to quickfix",
      mode = "n",
    },
    {
      "<leader>oD",
      "<cmd>lua vim.diagnostic.setloclist()<CR>",
      desc = "Give current buffer diagnostic to loclist",
      mode = "n",
    },
    {
      "<leader>oo",
      function()
        local bufnr = vim.api.nvim_get_current_buf()
        local lnum = vim.api.nvim_win_get_cursor(0)[1]
        local line = vim.api.nvim_get_current_line()

        vim.fn.setloclist(0, {
          {
            bufnr = bufnr,
            lnum = lnum,
            col = 1,
            text = vim.trim(line),
          },
        }, "a")

        -- require("quicker").toggle({ loclist = true })
      end,
      desc = "Add current line to loclist",
      mode = "n",
    },
  },
}
