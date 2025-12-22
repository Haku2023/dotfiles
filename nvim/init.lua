if vim.g.vscode then
  require("haku.vscode")
else
  require("haku.core")
end
require("haku.lazy")
