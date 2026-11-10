-- cat ~/.local/state/nvim/cmdheight.log
-- Temporary: find out what grows 'cmdheight'. Remove when solved.
local api = vim.api
local log_path = vim.fn.stdpath("state") .. "/cmdheight.log"
local keys = {}
local last = vim.o.cmdheight

-- Remember the last 40 keys you typed.
vim.on_key(function(_, typed)
  if typed and typed ~= "" then
    keys[#keys + 1] = vim.fn.keytrans(typed)
    if #keys > 40 then
      table.remove(keys, 1)
    end
  end
end)

local function report(msg)
  last = vim.o.cmdheight
  msg = msg .. "\nkeys: " .. table.concat(keys) .. "\n" .. vim.inspect(vim.fn.winlayout())
  vim.fn.writefile(vim.split(msg, "\n"), log_path, "a")
  vim.schedule(function()
    vim.notify(msg, vim.log.levels.WARN)
  end)
end

-- Wrap a function: if cmdheight changed while it ran, log who called it.
local function watch(name, fn)
  return function(...)
    local before = vim.o.cmdheight
    local results = vim.F.pack_len(fn(...))
    if vim.o.cmdheight ~= before then
      report(
        ("cmdheight %d -> %d in %s(%s)%s"):format(
          before,
          vim.o.cmdheight,
          name,
          vim.inspect(select(-1, ...)),
          debug.traceback("", 2)
        )
      )
    end
    return vim.F.unpack_len(results)
  end
end

api.nvim_win_set_height = watch("nvim_win_set_height", api.nvim_win_set_height)
local mt = getmetatable(vim.cmd) -- vim.cmd is a callable table; keep vim.cmd.xxx() working
mt.__call = watch("vim.cmd", mt.__call)

-- Catches Vimscript callers too, but without a Lua traceback.
api.nvim_create_autocmd("SafeState", {
  callback = function()
    if vim.o.cmdheight ~= last then
      report(("cmdheight %d -> %d (noticed after the command finished)"):format(last, vim.o.cmdheight))
    end
  end,
})
