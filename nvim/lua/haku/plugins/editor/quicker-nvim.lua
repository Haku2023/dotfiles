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
    },
  },
  keys = {
    {
      "<leader>q",
      function()
        require("quicker").toggle()
      end,
      desc = "Toggle quickfix",
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
  },
}
