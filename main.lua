-- Made by R0bl0x10501050
-- Source on GitHub: https://github.com/R0bl0x10501050/ThemeSwitcher
-- Refer to the Developer Forum post for more information (search "themeswitcher").
--- 

local ChangeHistoryService = game:GetService("ChangeHistoryService")

local toolbar = plugin:CreateToolbar("Theme Switcher")

local NewButton = toolbar:CreateButton("Open Widget", "Open selection widget", "rbxassetid://4458901886")
NewButton.ClickableWhenViewportHidden = true

local Widget
local Prompt

local colorSettings = {
	[['TODO' Color]],
	[['function' Color]],
	[['local' Color]],
	[['nil' Color]],
	[['self' Color]],
	--[[Active Color]]
	--[[Active Color Over Hover]]
	[[Background Color]],
	[[Bool Color]],
	[[Bracket Color]],
	[[Built-in Function Color]],
	[[Comment Color]],
	[[Current Line Highlight Color]],
	[[Debugger Current Line Color]],
	[[Debugger Error Line Color]],
	--[[Doc View Code Background Color]] -- Lacking permission 5
	[[Error Color]],
	[[Find Selection Background Color]],
	[[Function Name Color]],
	[[Hover Over Color]],
	[[Keyword Color]],
	[[Luau Keyword Color]],
	[[Matching Word Background Color]],
	[[Menu Item Background Color]],
	[[Method Color]],
	[[Number Color]],
	[[Operator Color]],
	--[[Pivot Snap To Geometry Color]]
	--[[Primary Text Color]] -- useleess
	[[Property Color]],
	[[Ruler Color]],
	[[Script Editor Scrollbar Background Color]],
	[[Script Editor Scrollbar Handle Color]],
	--[[ScriptEditorMenuBorderColor]]
	--[[Secondary Text Color]] -- useless
	[[Selection Color]],
	[[Selection Background Color]],
	[[String Color]],
	[[Text Color]],
	[[Warning Color]]
	-- I'm probably missing things...
}

local function getColor(name: string)
	return settings().Studio[name:gsub("'", "\"")]
end

local function setColor(name: string, color: Color3)
	settings().Studio[name:gsub("'", "\"")] = color
end

local function getJoined(text: string, color)
	return "<font color=\"rgb(" .. math.round(color[1] * 255) .. "," .. math.round(color[2] * 255) .. "," .. math.round(color[3] * 255) .. ")\">" .. text .. "</font>"
end

local function refreshList()
	local list = Widget:WaitForChild('ScrollingFrame').List.ScrollingFrame
	
	for _, child in ipairs(list:GetChildren()) do
		if child.Name ~= "Frame" and child:IsA("Frame") then
			child:Destroy()
		end
	end
	
	local data = plugin:GetSetting('studioThemes') or {}
	
	for _, theme in ipairs(data) do
		local entry = list.Frame:Clone()
		entry.Name = "Theme_" .. theme.name:gsub(' ', '')
		entry.Title.Text = theme.name
		
		local textColor = theme.colors[ [[Text Color]] ]
		local localColor = theme.colors[ [['local' Color]] ]
		local functionColor = theme.colors[ [['function' Color]] ]
		local functionNameColor = theme.colors[ [[Function Name Color]] ]
		local builtinColor = theme.colors[ [[Built-in Function Color]] ]
		local numberColor = theme.colors[ [[Number Color]] ]
		local stringColor = theme.colors[ [[String Color]] ]
		local keywordColor = theme.colors[ [[Keyword Color]] ]
		
		entry.CodeBlock.Text = getJoined("local", localColor) .. " " .. getJoined("function", functionColor) .. " " .. getJoined("foo", functionNameColor) .. "()<br />    " .. getJoined("print", builtinColor) .. "(" .. getJoined("8", numberColor) .. ", " .. getJoined("\"hi\"", stringColor) .. ")<br />" .. getJoined("end", keywordColor)
		entry.CodeBlock.TextColor3 = Color3.new(math.round(textColor[1] * 255), math.round(textColor[2] * 255), math.round(textColor[3] * 255))
		entry.Visible = true
		entry.Parent = list
		
		entry.Use.MouseButton1Click:Connect(function()
			for _, settingName in ipairs(colorSettings) do
				local color = theme.colors[settingName]
				if color then
					setColor(settingName, Color3.fromRGB(math.round(color[1] * 255), math.round(color[2] * 255), math.round(color[3] * 255)))
				else
					warn("[ThemeSwitcher] - Skipped property '"..settingName:gsub("'", "\"").."'")
				end
			end
		end)
	end
	
	list.CanvasSize = UDim2.new(0, 0, math.ceil(#data / 8))
end

NewButton.Click:Connect(function()
	local widgetInfo = DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Float,  -- Widget will be initialized in floating panel
		true,   -- Widget will be initially enabled
		false,  -- Don't override the previous enabled state
		350,    -- Default width of the floating window
		600,    -- Default height of the floating window
		175,    -- Minimum width of the floating window
		300     -- Minimum height of the floating window
	)
	
	local widgetInfo2 = DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Float,  -- Widget will be initialized in floating panel
		true,   -- Widget will be initially enabled
		false,  -- Don't override the previous enabled state
		400,    -- Default width of the floating window
		250,    -- Default height of the floating window
		200,    -- Minimum width of the floating window
		125     -- Minimum height of the floating window
	)
	
	if Widget == nil then
		Widget = plugin:CreateDockWidgetPluginGui("ThemeSwitcher", widgetInfo)
		Widget.Title = "Theme Switcher"
		Widget.Enabled = true
		
		script.Parent:WaitForChild('ScreenGui'):WaitForChild('ScrollingFrame').Parent = Widget
		
		Widget.ScrollingFrame.TextButton.MouseButton1Click:Connect(function()
			local newTheme = {
				colors = {},
				name = "Theme #" .. math.random(1, 1e4)
			}
			
			Prompt.Frame.TextBox.Text = ""
			Prompt.Enabled = true
			
			local connection
			connection = Prompt.Frame.TextButton.MouseButton1Click:Connect(function()
				Prompt.Enabled = false
				if Prompt.Frame.TextBox.Text ~= "" then
					newTheme.name = Prompt.Frame.TextBox.Text
					
					for _, settingName in ipairs(colorSettings) do
						local color = getColor(settingName)
						if color then
							newTheme.colors[settingName] = {
								color.R,
								color.G,
								color.B
							}
						else
							warn("[ThemeSwitcher] - Skipped property '"..settingName:gsub("'", "\"").."'")
						end
					end
					
					pcall(function()
						local oldData = plugin:GetSetting('studioThemes') or {}
						for i, dataslot in ipairs(oldData) do
							if dataslot.name == newTheme.name then
								oldData[i].colors = newTheme.colors
								plugin:SetSetting('studioThemes', oldData)
								return true
							end
						end
						table.insert(oldData, newTheme)
						plugin:SetSetting('studioThemes', oldData)
					end)
					
					task.wait() -- Wait for :SetSetting()
					refreshList()
				end
			end)
		end)
	else
		Widget.Enabled = not Widget.Enabled
	end
	
	refreshList()
	
	if Prompt == nil then
		Prompt = plugin:CreateDockWidgetPluginGui("ThemeSwitcherPrompt", widgetInfo2)
		Prompt.Title = "Theme Creation Prompt"
		Prompt.Enabled = false
		
		script.Parent:WaitForChild('ScreenGui'):WaitForChild('Frame').Parent = Prompt
	end
end)

_G.refreshThemes = function()
	if Widget then
		refreshList()
		return true
	else
		warn("[ThemeSwitcher DEBUG] - Plugin has not been launched!")
		return false
	end
end
