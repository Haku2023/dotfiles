-- define fortran-body in textobjects.scm
vim.treesitter.query.add_directive("fortran-body!", function(match, _, _, predicate, metadata)
  local inner = predicate[2]
  local header = predicate[3]
  local footer = predicate[4]
  local _, _, start_row, start_col = match[header][1]:range()
  local header_type = match[header][1]:type()
  if (header_type == "then" or header_type == "do_statement") and start_col > 0 then
    start_row = start_row + 1
    start_col = 0
  end
  local end_row = match[footer][1]:start()

  metadata[inner] = metadata[inner] or {}
  metadata[inner].range = { start_row, start_col, end_row, 0 }
end)
