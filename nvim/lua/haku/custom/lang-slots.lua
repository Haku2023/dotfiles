-- Programming Language Slots
-- prepare
local path = vim.fn.stdpath("config") .. "/lua/haku/data/lang-slots.json"
local function read_disk()
  if vim.fn.filereadable(path) == 0 then
    return "{}"
  end
  return table.concat(vim.fn.readfile(path), "\n")
end
local disk_snapshot = read_disk()
-- lang slot yank
local function save_lang_slots(lang, desc, text)
  -- add slots contents
  local ok, err = pcall(function()
    if read_disk() ~= disk_snapshot then
      error("lang slots changed on disk; restart or reload before saving")
    end
    local data = vim.json.decode(disk_snapshot)
    data[lang] = data[lang] or {}
    data[lang][desc] = text
    local encoded = vim.json.encode(data)
    if vim.fn.writefile({ encoded }, path) ~= 0 then
      error("Could not write " .. path)
    end
    disk_snapshot = encoded
  end)
  -- disk_snapshot = encoded
  --test
  -- local data = vim.json.decode(disk_snapshot)
  -- test
  -- vim.notify("disk_snapshot: ", disk_snapshot)
  -- vim.notify("data: " .. data)
  -- return true

  if not ok then
    vim.notify(tostring(err), vim.log.levels.ERROR)
    return false
  end

  vim.notify("Lang slots saved to " .. path)
  return true
end
-- lang slot paste
-- local function paste_lang_slot(lang, index)
--   local slots_paste = _G.HakuLangSlots[lang]
--   local text = slots_paste and slots_paste[index]
--
--   if text == nil or text == "" then
--     vim.notify(lang .. " slot " .. index .. " is empty", vim.log.levels.WARN)
--     return
--   end
--
--   vim.api.nvim_put(vim.split(text, "\n", { plain = true }), "c", true, true)
-- end
local function paste_from_preview(lang)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local previewers = require("telescope.previewers")

  -- local self var
  local data = vim.json.decode(disk_snapshot)
  local slot_paste = data[lang]
  local entries = {}
  for desc, content in pairs(slot_paste) do
    if content ~= "" then
      table.insert(entries, { desc = desc, content = content })
    end
  end

  pickers
    .new({}, {
      prompt_title = lang:sub(1, 1):upper() .. lang:sub(2) .. " Slots",
      finder = finders.new_table({
        results = entries,
        entry_maker = function(e)
          -- results list stays one line per slot; full content goes to preview
          -- local first = vim.split(e.content, "\n", { plain = true })[1]
          local display = string.format("%s", e.desc)
          return { value = e, display = display, ordinal = display }
        end,
      }),
      sorter = conf.generic_sorter({}),
      previewer = previewers.new_buffer_previewer({
        title = "Slot Contents",
        define_preview = function(self, entry)
          local lines = vim.split(entry.value.content, "\n", { plain = true })
          local preview_buf = self.state.bufnr
          local lang_hl
          vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, lines)
          if lang == "c++" then
            lang_hl = "cpp"
          elseif lang == "react" then
            lang_hl = "typescriptreact"
          else
            lang_hl = lang
          end
          require("telescope.previewers.utils").highlighter(preview_buf, lang_hl)
        end,
      }),
      attach_mappings = function(bufnr, map)
        actions.select_default:replace(function()
          actions.close(bufnr)
          local sel = action_state.get_selected_entry()
          if sel then
            vim.api.nvim_put(vim.split(sel.value.content, "\n", { plain = true }), "l", true, false)
          end
        end)
        map("n", "o", function()
          local sel = action_state.get_selected_entry()
          if not sel then
            return
          end

          local desc = sel.value.desc
          local lines = vim.split(sel.value.content, "\n", { plain = true })
          actions.close(bufnr)

          vim.cmd("new")
          local edit_buf = vim.api.nvim_get_current_buf()
          vim.api.nvim_buf_set_name(edit_buf, "lang-slot://" .. edit_buf)
          vim.bo[edit_buf].buftype = "acwrite"
          vim.bo[edit_buf].bufhidden = "wipe"
          vim.bo[edit_buf].filetype = lang
          vim.api.nvim_buf_set_lines(edit_buf, 0, -1, false, lines)
          vim.bo[edit_buf].modified = false

          vim.api.nvim_create_autocmd("BufWriteCmd", {
            buffer = edit_buf,
            callback = function()
              local edited_lines = vim.api.nvim_buf_get_lines(edit_buf, 0, -1, false)
              local text = table.concat(edited_lines, "\n")
              local slot_value = text ~= "" and text or nil
              if not save_lang_slots(lang, desc, slot_value) then
                error("Could not save slot " .. desc)
              end

              vim.bo[edit_buf].modified = false
            end,
          })
        end)
        return true
      end,
    })
    :find()
end
-- global table nil slots check
-- if _G.HakuLangSlots == nil then
--   local ok, data = pcall(function()
--     return vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
--   end)
--   if ok and type(data) == "table" then
--     _G.HakuLangSlots = data
--   else
--     _G.HakuLangSlots = {}
--   end
-- end
--
-- get selection
local function input_desc(lang)
  local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), {
    type = vim.fn.mode(),
    exclusive = vim.o.selection == "exclusive",
  })

  local text = table.concat(lines, "\n")
  vim.ui.input({ prompt = lang:sub(1, 1):upper() .. lang:sub(2) .. " Desc: " }, function(desc)
    if desc and desc ~= "" then
      save_lang_slots(lang, desc, text)
    end
  end)
end
for _, lang in ipairs({ "python", "fortran", "zsh", "typescript", "c++", "react" }) do
  vim.keymap.set("x", "<leader>yl" .. lang:sub(1, 1), function()
    input_desc(lang)
  end, { desc = "Yank to " .. lang .. " slots" })
  vim.keymap.set("n", "<leader>pl" .. lang:sub(1, 1), function()
    paste_from_preview(lang)
  end, { desc = "Paste from " .. lang .. " slots" })
end
-- end lang slots
