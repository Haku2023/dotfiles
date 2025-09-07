-- when enter insert clear highlight
local my_group = vim.api.nvim_create_augroup("mygroup", { clear = true })
vim.api.nvim_create_autocmd({ "InsertEnter" }, {
  group = my_group,
  callback = function()
    vim.schedule(function()
      vim.cmd("noh")
    end)
  end,
})
