local wezterm = require("wezterm")

local config = {}
local Background = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- basic system/tab/pane settings
-- <<<fold-start
-- system setting
config.default_workspace = "apple"
-- force X11 instead of Wayland
config.enable_wayland = true
-- tab settting
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.audible_bell = "Disabled"
config.hide_tab_bar_if_only_one_tab = false
-- pane setting
config.unzoom_on_switch_pane = false
-- set for wsl if windows, using <C-S-l> check info
-- <<<fold-end

-- font, background settings
-- <<<fold-start
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	config.default_prog = { "wsl.exe", "~", "-e", "zsh" }
	wezterm.log_info("OS: Windows, Prog: wsl")
	-- config.default_prog = { "C:\\Program Files\\PowerShell\\7\\pwsh.exe" }
	-- config.default_prog = { "C:\\cygwin64\\bin\\zsh.exe", "-l" }
	-- wezterm.log_info("OS: Windows, Prog: cygwin")
	config.font_size = 17
	config.font = wezterm.font("JetBrains Mono NL", { weight = "Medium", stretch = "Normal", style = "Normal" })
elseif wezterm.target_triple == "aarch64-apple-darwin" then
	wezterm.log_info("OS: Mac")
	-- font setting
	-- config.font = wezterm.font("MesloLGS NF", { weight = "Medium", stretch = "Normal", style = "Normal" })
	config.font = wezterm.font("JetBrains Mono NL", { weight = "Regular", stretch = "Normal", style = "Normal" })
	config.font_size = 24
	Gotop = "/usr/local/bin/gotop"
	HOME = os.getenv("HOME")
	-- HOME = wezterm.home_dir
	config.window_background_opacity = 1.00
	Background = {
		{
			source = {
				-- File = HOME .. "/Pictures/WallPaper/cybercity-keepforward.jpg",
				-- File = HOME .. "/Pictures/WallPaper/fuji-maples.jpg",
			},
			-- hsb = { brightness = 0.2 },
			opacity = 1.0,
			attachment = "Fixed",
		},
		{
			source = {
				Color = "black",
				-- Gradient = { preset = "Warm" },
			},
			height = "100%",
			width = "100%",
			opacity = 0.5,
		},
	}
elseif wezterm.target_triple == "x86_64-unknown-linux-gnu" then
	wezterm.log_info("OS: Linux")
	config.font_size = 17
	Gotop = "gotop"
	config.window_background_opacity = 0.50
	-- font setting
	config.font = wezterm.font("JetBrains Mono NL", { weight = "Regular", stretch = "Normal", style = "Normal" })
	-- config.font = wezterm.font("MesloLGS NF", { weight = "Medium", stretch = "Normal", style = "Normal" })
end
-- config.font = wezterm.font("MesloLGS NF")
--
-- window setting
-- to make windows resized also can exclude the top bar
config.window_decorations = "NONE"
-- config.window_decorations = "RESIZE"
-- config.window_close_confirmation = "NeverPrompt"
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
-- <<<fold-end

-- workspace setting from start
-- <<<fold-start
if wezterm.target_triple ~= "x86_64-pc-windows-msvc" then
	wezterm.on("gui-startup", function(cmd)
		local mux = wezterm.mux
		local workspace_name = "banana"
		-- First, spawn the default "apple" workspace window
		local tab, pane, window = mux.spawn_window(cmd or {})
		-- Then create "banana" workspace in the background with 2 tabs
		local _, _, banana_window = mux.spawn_window({
			workspace = workspace_name,
			-- add dotfiles in banana workspace
			cwd = wezterm.home_dir .. "/dotfiles",
		})
		banana_window:spawn_tab({
			cwd = wezterm.home_dir .. "/Haku_Posts",
		})
		mux.set_active_workspace(config.default_workspace)
		if wezterm.target_triple ~= "x86_64-unknown-linux-gnu" then
			window:gui_window():toggle_fullscreen()
		end
	end)
else
	wezterm.on("gui-startup", function(cmd)
		local mux = wezterm.mux
		local workspace_name = "melon"
		-- First, spawn the default "apple" workspace window
		local _, _, _ = mux.spawn_window(cmd or {})

		-- Then create "melon" workspace in the background with 2 tabs
		local tab, pane, melon_window = mux.spawn_window({
			workspace = workspace_name,
			cwd = wezterm.home_dir,
		})

		-- Open the pwshh.exe in the new tab of the "melon" workspace
		-- melon_window:spawn_tab({
		-- 	cwd = wezterm.home_dir,
		-- 	args = { "C:\\Users\\hakukt\\AppData\\Local\\Microsoft\\WindowsApps\\pwsh.exe" },
		-- })
	end)
end
-- <<<fold-end

-- color scheme setting
-- windows one half black, mac and linux one black
-- <<<fold-start
config.color_scheme = "Dracula (Official)"
config.color_scheme_dirs = { "~/.config/color/schemes" }
-- Josean coolnight colorscheme:
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	config.colors = {
		foreground = "#CBE0F0",
		--one half black
		background = "#282c34",
		cursor_fg = "#282c34",
		-- background = "#011423",
		-- cursor_fg = "#011423",
		cursor_bg = "#47FF9C",
		cursor_border = "#47FF9C",
		selection_bg = "#033259",
		selection_fg = "#CBE0F0",
		ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#a277ff", "#24EAF7", "#24EAF7" },
		brights = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#A277FF", "#a277ff", "#24EAF7", "#24EAF7" },
	}
	-- config.ime_preedit_rendering = "System"
else
	config.colors = {
		foreground = "#CBE0F0",
		--one half black
		-- background = "#282c34",
		-- cursor_fg = "#282c34",
		background = "#011423",
		-- background = "#000000",
		cursor_fg = "#011423",
		cursor_bg = "#47FF9C",
		cursor_border = "#47FF9C",
		selection_bg = "#033259",
		selection_fg = "#CBE0F0",
		ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#a277ff", "#24EAF7", "#24EAF7" },
		brights = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#A277FF", "#a277ff", "#24EAF7", "#24EAF7" },
	}
end
-- <<<fold-end

-- functions and register events
--<<<fold-start
-- Pane roles use stable IDs, so rearranging splits does not change the main pane.
local function main_pane(tab)
	local roles = wezterm.GLOBAL.main_panes or {}
	local id = tostring(tab:tab_id())
	local panes = tab:panes()
	local oldest
	for _, pane in ipairs(panes) do
		if pane:pane_id() == roles[id] then
			return pane
		end
		if not oldest or pane:pane_id() < oldest:pane_id() then
			oldest = pane
		end
	end
	-- Also initializes existing tabs on reload; promote the oldest survivor on close.
	if oldest then
		roles[id] = oldest:pane_id()
		wezterm.GLOBAL.main_panes = roles
	end
	return oldest
end

local function focus_zoomed(tab, pane)
	if not pane then
		return
	end
	if tab:active_pane():pane_id() ~= pane:pane_id() then
		-- Required by WezTerm before activating a different zoomed pane.
		tab:set_zoomed(false)
		pane:activate()
	end
	tab:set_zoomed(true)
end

local function show_main_pane(tab)
	focus_zoomed(tab, main_pane(tab))
end

local function activate_main_tab(window, tab)
	local current = window:active_tab()
	if current and current:tab_id() ~= tab:tab_id() then
		local previous = wezterm.GLOBAL.previous_tabs or {}
		previous[tostring(window:window_id())] = current:tab_id()
		wezterm.GLOBAL.previous_tabs = previous
	end
	show_main_pane(tab)
	tab:activate()
end

local function switch_workspace(window, pane, name)
	if not name then
		return
	end
	-- Prepare destination windows before they become visible.
	for _, mux_window in ipairs(wezterm.mux.all_windows()) do
		if mux_window:get_workspace() == name then
			local tab = mux_window:active_tab()
			if tab then
				show_main_pane(tab)
			end
		end
	end
	local current = window:active_workspace()
	if current ~= name then
		wezterm.GLOBAL.previous_workspace = current
	end
	window:perform_action(wezterm.action.SwitchToWorkspace({ name = name }), pane)
end

local function relative_workspace(offset)
	return wezterm.action_callback(function(window, pane)
		local names = wezterm.mux.get_workspace_names()
		table.sort(names)
		for i, name in ipairs(names) do
			if name == window:active_workspace() then
				switch_workspace(window, pane, names[(i - 1 + offset) % #names + 1])
				return
			end
		end
	end)
end

-- workspace setting
-- create workspace
wezterm.on("create-workspace", function(window, pane)
	-- window:set_right_status("hahah")
	window:perform_action(
		wezterm.action.PromptInputLine({
			description = wezterm.format({
				{ Attribute = { Intensity = "Bold" } },
				{ Foreground = { AnsiColor = "Fuchsia" } },
				{ Text = " Enter name for new workspace" },
			}),
			action = wezterm.action_callback(function(window_i, pane_i, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line then
					if line ~= "" then
						switch_workspace(window_i, pane_i, line)
					end
				end
			end),
		}),
		pane
	)
end)
-- select existed workspace
wezterm.on("select-workspace", function(window, pane)
	local workspace_names = wezterm.mux.get_workspace_names()
	local choices = {}
	for i, name in ipairs(workspace_names) do
		table.insert(choices, {
			label = wezterm.format({
				{ Attribute = { Intensity = "Bold" } },
				{ Foreground = { Color = "Coral" } },
				{ Text = tostring(i) .. " " },
				{ Attribute = { Intensity = "Bold" } },
				{ Foreground = { Color = "Orange" } },
				{ Text = name },
			}),
			id = name,
		})
	end
	-- window:set_right_status(workspace_names[2])
	window:perform_action(
		wezterm.action.InputSelector({
			-- title = "Select WorkSpace : ",
			fuzzy = true,
			fuzzy_description = wezterm.format({
				{ Attribute = { Intensity = "Bold" } },
				{ Foreground = { AnsiColor = "Fuchsia" } },
				{ Text = " Fyzzy find name for new workspace : " },
			}),

			choices = choices,
			action = wezterm.action_callback(function(window_i, pane_i, id, label)
				-- window:set_right_status(workspace_names[2])
				if not id and not label then
					wezterm.log_info("cancelled")
				else
					-- wezterm.log_info("you selected ", id, label)
					-- pane_i:send_text(id)
					switch_workspace(window_i, pane_i, id)
				end
			end),
		}),
		pane
	)
end)
-- swap workspace
wezterm.on("swap-workspace", function(window, pane)
	local current = window:active_workspace()
	local previous = wezterm.GLOBAL.previous_workspace

	if not previous or previous == current then
		wezterm.GLOBAL.previous_workspace = current
		return
	end

	switch_workspace(window, pane, previous)
end)

-- set toggle tab bar
wezterm.on("toggle-tab-bar", function(window, _)
	local overrides = window:get_config_overrides() or {}
	local enabled = overrides.enable_tab_bar
	if enabled == nil then
		enabled = config.enable_tab_bar
	end
	overrides.enable_tab_bar = not enabled
	window:set_config_overrides(overrides)
end)
wezterm.on("update-status", function(window, _)
	local date = wezterm.strftime("%Y-%m-%d %H:%M:%S")
	-- local date = wezterm.strftime("%Y-%m-%d %H:%M:%S %Z %z")
	window:set_right_status(wezterm.format({
		{ Attribute = { Underline = "None" } },
		{
			Text = wezterm.nerdfonts.fa_clock_o
				.. " "
				.. date
				.. " "
				.. wezterm.nerdfonts.md_home_modern
				.. " nvim_v4-3-transparent "
				.. wezterm.nerdfonts.oct_versions
				.. " "
				.. window:active_workspace(),
		},
	}))
end)
-- Previous tab is tracked by stable ID, separately for each window.
wezterm.on("swap-tab", function(window, _)
	local previous = (wezterm.GLOBAL.previous_tabs or {})[tostring(window:window_id())]
	for _, tab in ipairs(window:mux_window():tabs()) do
		if tab:tab_id() == previous then
			activate_main_tab(window, tab)
			return
		end
	end
	show_main_pane(window:active_tab())
end)

wezterm.on("format-tab-title", function(tab)
	local roles = wezterm.GLOBAL.main_panes or {}
	local main_id = roles[tostring(tab.tab_id)]
	if not main_id then
		for _, pane in ipairs(tab.panes) do
			if not main_id or pane.pane_id < main_id then
				main_id = pane.pane_id
			end
		end
	end
	local role = tab.active_pane.pane_id == main_id and "main_pane" or "sub_pane"
	return " " .. tostring(tab.tab_index + 1) .. ": " .. role .. " "
end)

-- opacity change / toggle background image
wezterm.on("toggle-background-image", function(window, _)
	local overrides = window:get_config_overrides() or {}
	if not overrides.background then
		overrides.background = Background
	else
		overrides.background = nil
		-- config.window_background_opacity = 0.80
	end
	window:set_config_overrides(overrides)
end)
-- toggle background opacity
wezterm.on("toggle-background-opacity", function(window, _)
	local overrides = window:get_config_overrides() or {}
	local tag = overrides.window_background_opacity
	local current_opacity = tag or config.window_background_opacity
	if current_opacity ~= 0.7 then
		overrides.window_background_opacity = 0.7
	else
		overrides.window_background_opacity = 1.0
	end
	window:set_config_overrides(overrides)
end)
wezterm.on("down-opacity", function(window, _)
	local overrides = window:get_config_overrides() or {}
	local tag = overrides.window_background_opacity
	local current_opacity = tag or config.window_background_opacity
	overrides.window_background_opacity = current_opacity - 0.05
	window:set_config_overrides(overrides)
end)
wezterm.on("up-opacity", function(window, _)
	local overrides = window:get_config_overrides() or {}
	local tag = overrides.window_background_opacity
	local current_opacity = tag or config.window_background_opacity
	overrides.window_background_opacity = tag and tag >= 1.0 and 1.0 or current_opacity + 0.05
	window:set_config_overrides(overrides)
end) --

-- Alt-e toggles main/sub; additional panes cycle in creation order.
wezterm.on("swap-pane-new", function(window, pane)
	local tab = window:active_tab()
	main_pane(tab) -- Register the original pane before the first split.
	local panes = tab:panes()
	if #panes == 1 then
		local sub = pane:split({ direction = "Bottom" })
		focus_zoomed(tab, sub)
		return
	end
	table.sort(panes, function(a, b)
		return a:pane_id() < b:pane_id()
	end)
	for i, candidate in ipairs(panes) do
		if candidate:pane_id() == pane:pane_id() then
			focus_zoomed(tab, panes[i % #panes + 1])
			return
		end
	end
end)

local function jump_to_tab(n)
	return wezterm.action_callback(function(window, _)
		for _, entry in ipairs(window:mux_window():tabs_with_info()) do
			if entry.index == n - 1 then
				activate_main_tab(window, entry.tab)
				return
			end
		end
	end)
end
-- haku test use <A-r>
wezterm.on("show_status", function(window, pane)
	local tab = window:active_tab()
	-- local panes = pane.split(dir)
	local new_pane = pane:split({ Direction = "Right" })
	-- pane:split({ Direction = "Right", top_level = true })
	window:perform_action(wezterm.action.SetPaneZoomState(true), new_pane)
	-- new_pane:activate()
	-- window:set_right_status("This is test for <A-r> show status")
	-- window:set_right_status("number of panes in current tab:" .. #tab:panes())
	-- window:set_right_status(Background and "BG:ON" or "BG:OFF")
	-- use C-S-L to show the debug info
	local overrides = window:get_config_overrides() or {}
	wezterm.log_info(wezterm.json_encode(overrides.background[1].source))
	-- wezterm.log_info(wezterm.json_encode(overrides.backgorund))
end)

-- Define a "launcher" window class for floating prompts
-- wezterm.on("config-reload", function()
-- 	wezterm.window.set_window_class("launcher", {
-- 		-- Dimensions in cells (width x height)
-- 		width = 80,
-- 		height = 10,
--
-- 		-- Remove window decorations for a minimal look
-- 		window_decorations = "NONE",
--
-- 		-- Position it in the center of the screen
-- 		position = {
-- 			x = "50%",
-- 			y = "45%", -- A little above center looks nice
-- 		},
--
-- 		-- Make it a floating window that stays on top
-- 		is_floating = true,
-- 	})
-- end)
--<<<fold-end
--
-- shortcut setting
-- <<<fold-start
local act = wezterm.action
config.keys = {
	-- Disable L,d,u
	-- { key = "L", mods = "CTRL|SHIFT", action = "DisableDefaultAssignment" }, -- disables the debug overlay
	{ key = "Enter", mods = "CTRL", action = act.Nop },
	{ key = "d", mods = "CTRL", action = "DisableDefaultAssignment" }, -- disables the debug overlay
	{ key = "u", mods = "CTRL", action = "DisableDefaultAssignment" }, -- disables the debug overlay
	{ key = "p", mods = "CTRL|SHIFT", action = "DisableDefaultAssignment" }, -- disables
	{ key = "n", mods = "CTRL|SHIFT", action = "DisableDefaultAssignment" }, -- disables
	{ key = "x", mods = "ALT", action = "ActivateCopyMode" },
	-- { key = "w", mods = "CTRL", action = "DisableDefaultAssignment" }, -- disables the debug overlay
	-- { key = "q", mods = "CTRL|SHIFT", action = "DisableDefaultAssignment" }, -- disables the debug overlay
	-- Alt(Opt)+Shift+F toggle full screen
	{ key = "f", mods = "SHIFT|META", action = wezterm.action.ToggleFullScreen },
	-- Ctrl+Shift+t Create a new tab
	{ key = "t", mods = "SHIFT|CTRL", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "t", mods = "ALT", action = act.EmitEvent("toggle-tab-bar") },
	-- Tabs manipulation
	-- Shift Size of Pane
	{ key = "h", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Left", 1 }) },
	{ key = "l", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Right", 1 }) },
	{ key = "j", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Down", 1 }) },
	{ key = "k", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Up", 1 }) },
	-- Pane navigation (like Vim: Alt+h/j/k/l)
	-- Alt + h used for delete word in nvim
	-- { key = "h", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Left") },
	-- { key = "l", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Right") },
	-- { key = "k", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Up") },
	-- { key = "j", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Down") },
	{ key = "k", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Right") },
	{ key = "j", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Left") },
	-- Pane max
	{ key = "m", mods = "ALT", action = wezterm.action.TogglePaneZoomState },
	-- Swap Pane
	{ key = "e", mods = "ALT", action = act.EmitEvent("swap-pane-new") },
	-- Swap Tab
	{ key = "o", mods = "ALT", action = act.EmitEvent("swap-tab") },
	-- Test
	{ key = "r", mods = "ALT", action = act.EmitEvent("show_status") },
	-- quick selectmode
	{ key = "y", mods = "ALT", action = wezterm.action.QuickSelect },
	-- Optional: split panes
	{ key = "v", mods = "ALT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "s", mods = "ALT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	-- Optional: Close current pane
	{ key = "w", mods = "ALT", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
	{ key = "w", mods = "ALT|SHIFT", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
	-- { key = "w", mods = "ALT", action = wezterm.action.CloseCurrentTab({ confirm = true }) },
	-- { key = "w", mods = "ALT|SHIFT", action = wezterm.action.CloseCurrentTab({ confirm = false }) },
	-- Scroll lines using alt
	-- { key = "n", mods = "ALT", action = wezterm.action.ScrollByLine(5) },
	-- { key = "p", mods = "ALT", action = wezterm.action.ScrollByLine(-5) },
	-- change opacity
	{ key = "-", mods = "ALT", action = act.EmitEvent("down-opacity") },
	{ key = "=", mods = "ALT", action = act.EmitEvent("up-opacity") },
	{ key = "0", mods = "ALT", action = act.EmitEvent("toggle-background-opacity") },
	{ key = "1", mods = "ALT", action = jump_to_tab(1) },
	{ key = "2", mods = "ALT", action = jump_to_tab(2) },
	{ key = "3", mods = "ALT", action = jump_to_tab(3) },
	{ key = "4", mods = "ALT", action = jump_to_tab(4) },
	-- { key = "0", mods = "ALT", action = act.EmitEvent("toggle-background-image") },
	-- workspace
	-- { key = ",", mods = "ALT", action = act.SwitchWorkspaceRelative(-1) },
	-- { key = ".", mods = "ALT", action = act.SwitchWorkspaceRelative(1) },
	{ key = ",", mods = "ALT", action = relative_workspace(-1) },
	{ key = ".", mods = "ALT", action = relative_workspace(1) },
	{ key = "/", mods = "ALT", action = act.EmitEvent("select-workspace") },
	{ key = "n", mods = "ALT|SHIFT", action = act.EmitEvent("create-workspace") },
	{ key = "n", mods = "ALT", action = act.EmitEvent("swap-workspace") },
	-- new tab as powershell
	-- Ctrl+Shift+P will open a new tab running PowerShell
	{
		key = "P",
		mods = "ALT|SHIFT",
		action = act.SpawnCommandInNewTab({
			args = { "C:\\Program Files\\PowerShell\\7\\pwsh.exe" }, -- or "pwsh.exe" for PowerShell 7
		}),
	},
	-- Ctrl+Shift+P will open a new tab running PowerShell
	{
		key = "o",
		mods = "ALT|SHIFT",
		action = act.SpawnCommandInNewTab({
			args = { Gotop },
		}),
	},
	-- specific for open qutebrowser and switch to 73
	{
		key = "q",
		mods = "CTRL|SHIFT",

		action = wezterm.action_callback(function(_, _)
			-- AppleScript: tell App B to activate (focus/launch)
			wezterm.background_child_process({
				"osascript",
				"-e",
				'tell application "qutebrowser" to activate',
			})
		end),
	},
	{
		key = "w",
		mods = "CTRL",

		action = wezterm.action_callback(function(_, _)
			-- AppleScript: tell App B to activate (focus/launch)
			wezterm.background_child_process({
				"osascript",
				"-e",
				'tell application "System Events"',
				"-e",
				'tell process "Microsoft Remote Desktop"',
				"-e",
				"set frontmost to true",
				"-e",
				'click menu item "10.244.7.73" of menu 1 of menu bar item "Window" of menu bar 1',
				"-e",
				"end tell",
				"-e",
				"end tell",
			})

			-- ... rest of your config ...
		end),
	},
	-- notification
	{
		key = "9",
		mods = "ALT",
		action = wezterm.action_callback(function(window, _)
			window:toast_notification("wezterm", "configuration reloaded!", nil, 1000)
			-- wezterm.log_info("hello")
		end),
	},

	-- not used for some reference
	--[[ {key = "LeftArrow",mods = "CTRL",action = act.SendKey({key = "b",mods = "META",}),},
	{ key = "¥", mods = "", action = wezterm.action.SendString("\\") },
	{ key = "1", mods = "ALT", action = wezterm.action.ActivatePaneByIndex(0) },
	{ key = "p", mods = "SHIFT", action = wezterm.action.PasteFrom "Clipboard",}, ]]
	-- Alt(Opt)+Shift+Fでフルスクリーン切り替え
	-- if in linux, using tab alt to change workspace
	-- if string.find(wezterm.target_triple, "linux") or string.find(wezterm.target_triple, "apple") then
	-- 	-- table.insert(config.keys, { key = "Tab", mods = "ALT", action = act.EmitEvent("swap-workspace") })
	-- end
}
-- <<<fold-end

return config
