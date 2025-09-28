local wezterm = require("wezterm")

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- system setting
config.default_workspace = "apple"
-- set for wsl if windows, using <C-S-l> check info{{{
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	config.default_prog = { "wsl.exe", "~", "-e", "zsh" }
	wezterm.log_info("OS: Windows, Prog: wsl")
	-- config.default_prog = { "C:\\Program Files\\PowerShell\\7\\pwsh.exe" }
	-- config.default_prog = { "C:\\cygwin64\\bin\\zsh.exe", "-l" }
	-- wezterm.log_info("OS: Windows, Prog: cygwin")
	config.font_size = 17
elseif wezterm.target_triple == "aarch64-apple-darwin" then
	wezterm.log_info("OS: Mac")
	config.font_size = 21
	Gotop = "/usr/local/bin/gotop"
	config.background = {
		{
			source = {
				File = "${HOME}/Pictures/WallPaper/cybercity-chinatown.jpg",
			},
			width = "100%",
			-- repeat_x = "Mirror",
			hsb = { brightness = 0.5 },
			attachment = "Fixed",
		},
	}
elseif wezterm.target_triple == "x86_64-unknown-linux-gnu" then
	wezterm.log_info("OS: Linux")
	config.font_size = 17
	Gotop = "gotop"
end -- }}}
-- font setting
config.font = wezterm.font("MesloLGS NF", { weight = "Medium", stretch = "Normal", style = "Normal" })
-- config.font = wezterm.font("MesloLGS NF")
config.background = {
	{
		source = {
			File = "/Users/bai.haodong/Pictures/WallPaper/cybercity-keepforward.jpg",
		},
		hsb = { brightness = 0.2 },
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

-- define one or more remote hosts
-- config.ssh_domains = {
-- 	{
-- 		name = "117",
-- 		remote_address = "10.244.7.117",
-- 		username = "baihaodong",
-- 	},
-- }

-- test-show
wezterm.on("show_status", function(window, _)
	window:set_right_status("This is test for <C-r> show status")
end)

-- workspace setting
-- create workspace{{{
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
					window_i:perform_action(wezterm.action.SwitchToWorkspace({ name = line }), pane_i)
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
					window_i:perform_action(wezterm.action.SwitchToWorkspace({ name = id }), pane_i)
				end
			end),
		}),
		pane
	)
end)
-- swap workspace
wezterm.on("swap-workspace", function(window, pane)
	_G.workspace_p = _G.workspace_p or "0"

	-- window:set_right_status(_G.workspace_p)

	local current_workspace_name = window:active_workspace()
	local workspace_p_name = nil

	-- window:set_right_status("pindex pure: " .. tostring(G.pane_pindex))
	-- if nil, give current index and toggle maximum return
	if _G.workspace_p ~= "0" then
		workspace_p_name = _G.workspace_p
		_G.workspace_p = current_workspace_name
		-- window:perform_action(wezterm.action.SetPaneZoomState(false), pane)
		window:perform_action(wezterm.action.SwitchToWorkspace({ name = workspace_p_name }), pane)
	else
		_G.workspace_p = current_workspace_name
	end
end)
-- }}}

-- tab settting
config.enable_tab_bar = true
--{{{
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.audible_bell = "Disabled"
config.hide_tab_bar_if_only_one_tab = false
-- set toggle tab bar
wezterm.on("toggle-tab-bar", function(window, _)
	local overrides = window:get_config_overrides() or {}
	overrides.enable_tab_bar = not overrides.enable_tab_bar
	window:set_config_overrides(overrides)
end)
wezterm.on("update-status", function(window, _)
	local date = wezterm.strftime("%Y-%m-%d %H:%M:%S")
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
-- }}}

-- window setting
-- to make windows resized also can exclude the top bar
-- config.window_background_opacity = 0.80
config.window_decorations = "RESIZE" -- {{{
-- config.window_close_confirmation = "NeverPrompt"
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
-- full screen from start
local mux = wezterm.mux
wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():toggle_fullscreen()
end)

-- opacity change
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
end) -- }}}

-- pane setting
config.unzoom_on_switch_pane = false
-- wezterm.GLOBAL.pane_pindex = {}
-- swap pane haku{{{
wezterm.on("swap-pane", function(window, pane)
	_G.pane_pindex = _G.pane_pindex or {}
	local tab = window:active_tab()
	local itab = tab:tab_id()
	local index_p

	-- window:set_right_status("pindex pure: " .. tostring(G.pane_pindex))
	-- window:set_right_status("tab id: " .. tostring(tab:tab_id()) .. " pane id: " .. tostring(_G.pane_pindex[itab]))
	-- if nil, give current index and toggle maximum return
	if _G.pane_pindex[itab] ~= nil then
		index_p = _G.pane_pindex[itab]
		-- window:set_right_status("pindex not nil:" .. tostring(index_p))
		for _, p in ipairs(tab:panes_with_info()) do
			if p.is_active and p.is_zoomed and p.index ~= index_p then
				_G.pane_pindex[itab] = p.index
				window:perform_action(wezterm.action.SetPaneZoomState(false), pane)
				window:perform_action(wezterm.action.ActivatePaneByIndex(index_p), pane)
				window:perform_action(wezterm.action.SetPaneZoomState(true), pane)
				-- window:set_right_status("Pane asId:" .. tostring(id))
				-- window:set_right_status("Pane_list:" .. table.concat(_G.pane_list, "|"))
			end
		end
	else
		for _, p in ipairs(tab:panes_with_info()) do
			if p.is_active and p.is_zoomed then
				window:set_right_status("pindex in active:" .. tostring(_G.pane_pindex))
				_G.pane_pindex[itab] = p.index
				window:perform_action(wezterm.action.SetPaneZoomState(false), pane)
				return
			end
		end
	end
end) -- }}}

-- color scheme setting
config.color_scheme = "Dracula (Official)"
config.color_scheme_dirs = { "~/.config/color/schemes" } -- {{{
-- Josean coolnight colorscheme:
config.colors = {
	foreground = "#CBE0F0",
	background = "#011423",
	cursor_bg = "#47FF9C",
	cursor_border = "#47FF9C",
	cursor_fg = "#011423",
	selection_bg = "#033259",
	selection_fg = "#CBE0F0",
	ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#a277ff", "#24EAF7", "#24EAF7" },
	brights = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#A277FF", "#a277ff", "#24EAF7", "#24EAF7" },
} -- }}}

-- shortcut setting
local act = wezterm.action
config.keys = { -- {{{

	-- Disable L,d,u
	-- { key = "L", mods = "CTRL|SHIFT", action = "DisableDefaultAssignment" }, -- disables the debug overlay
	{ key = "d", mods = "CTRL", action = "DisableDefaultAssignment" }, -- disables the debug overlay
	{ key = "u", mods = "CTRL", action = "DisableDefaultAssignment" }, -- disables the debug overlay
	-- { key = "w", mods = "CTRL", action = "DisableDefaultAssignment" }, -- disables the debug overlay
	-- { key = "q", mods = "CTRL|SHIFT", action = "DisableDefaultAssignment" }, -- disables the debug overlay
	-- Alt(Opt)+Shift+F toggle full screen
	{ key = "f", mods = "SHIFT|META", action = wezterm.action.ToggleFullScreen },
	-- Ctrl+Shift+t Create a new tab
	{ key = "t", mods = "SHIFT|CTRL", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "t", mods = "META", action = act.EmitEvent("toggle-tab-bar") },
	-- Tabs manipulation
	-- Shift Size of Pane
	{ key = "h", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Left", 1 }) },
	{ key = "l", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Right", 1 }) },
	{ key = "j", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Down", 1 }) },
	{ key = "k", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Up", 1 }) },
	-- Pane navigation (like Vim: Alt+h/j/k/l)
	{ key = "h", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Left") },
	{ key = "l", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Right") },
	{ key = "k", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Up") },
	{ key = "j", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Down") },
	-- Pane max
	{ key = "f", mods = "ALT", action = wezterm.action.TogglePaneZoomState },
	-- Swap Pane
	{ key = "e", mods = "ALT", action = act.EmitEvent("swap-pane") },
	-- Test
	{ key = "r", mods = "ALT", action = act.EmitEvent("show_status") },
	-- quick selectmode
	{ key = "y", mods = "ALT", action = wezterm.action.QuickSelect },
	-- Optional: split panes
	{ key = "v", mods = "ALT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "s", mods = "ALT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	-- Optional: Close current pane
	{ key = "w", mods = "ALT", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
	-- Scroll lines using alt
	{ key = "n", mods = "ALT", action = wezterm.action.ScrollByLine(5) },
	{ key = "p", mods = "ALT", action = wezterm.action.ScrollByLine(-5) },
	-- change opacity
	{ key = "-", mods = "ALT", action = act.EmitEvent("down-opacity") },
	{ key = "=", mods = "ALT", action = act.EmitEvent("up-opacity") },
	-- workspace
	{ key = ",", mods = "ALT", action = act.SwitchWorkspaceRelative(-1) },
	{ key = ".", mods = "ALT", action = act.SwitchWorkspaceRelative(1) },
	{ key = "/", mods = "ALT", action = act.EmitEvent("select-workspace") },
	{ key = "n", mods = "ALT|SHIFT", action = act.EmitEvent("create-workspace") },
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
		mods = "ALT",
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
	-- Alt(Opt)+Shift+Fでフルスクリーン切り替え}}}
}

-- if in linux, using tab alt to change workspace
if string.find(wezterm.target_triple, "linux") or string.find(wezterm.target_triple, "apple") then
	table.insert(config.keys, { key = "Tab", mods = "ALT", action = act.EmitEvent("swap-workspace") })
end

return config
