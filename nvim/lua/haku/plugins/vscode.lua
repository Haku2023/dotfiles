local specs = {}

vim.list_extend(specs, require("haku.vscode.basic"))
table.insert(specs, require("haku.vscode.flash"))

return specs
