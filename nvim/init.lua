if vim.g.vscode then
  -- If running in VS Code, prepend path to ensure read toinit.lua
  vim.opt.rtp:prepend(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h"))
  require("haku.vscode")
else
  require("haku.core")
end
require("haku.lazy")
