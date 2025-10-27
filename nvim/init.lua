if vim.g.vscode then
  require("haku.vscode_core")
else
  require("haku.core")
end
require("haku.lazy")
