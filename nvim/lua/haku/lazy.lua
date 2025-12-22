local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

if vim.g.vscode then
  require("lazy").setup({ { import = "haku.plugins.vscode" } }, {
    install = {
      colorscheme = { "nightfily" },
    },
    checker = {
      enabled = true,
      notify = false,
    },
    change_detection = {
      notify = false,
    },
  })
else
  require("lazy").setup({
    { import = "haku.plugins" },
    { import = "haku.plugins.ui" },
    { import = "haku.plugins.editor" },
    { import = "haku.plugins.navigation" },
    { import = "haku.plugins.coding" },
    { import = "haku.plugins.tools" },
    { import = "haku.plugins.lsp" },
  }, {
    install = {
      colorscheme = { "nightfily" },
    },
    checker = {
      enabled = true,
      notify = false,
    },
    change_detection = {
      notify = false,
    },
  })
end
