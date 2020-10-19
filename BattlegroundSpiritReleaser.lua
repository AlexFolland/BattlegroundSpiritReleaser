--undeprecate InActiveBattlefield
if InActiveBattlefield == nil then
	function InActiveBattlefield()
		return C_PvP.IsActiveBattlefield()
	end
end

--default values for options saved between sessions
local BattlegroundSpiritReleaserDBDefaults = {
	Enabled = true,
	UseSoulstone = true,
	SoulstoneDelay = 0
}

local maxSoulstoneDelay = 20

--function to initialize missing saved variables with default values
local function InitializeBattlegroundSpiritReleaserDB(defaults)
	if BattlegroundSpiritReleaserDB == nil then BattlegroundSpiritReleaserDB = {} end
	for k,v in pairs(defaults) do
		if BattlegroundSpiritReleaserDB[k] == nil then
			BattlegroundSpiritReleaserDB[k] = defaults[k]
		end
	end
end

--option setters
local function ToggleBattlegroundSpiritReleaser(force, shouldPrint)
	if BattlegroundSpiritReleaserDB.Enabled == nil then InitializeBattlegroundSpiritReleaserDB(BattlegroundSpiritReleaserDBDefaults) end
	if force ~= nil then BattlegroundSpiritReleaserDB.Enabled = force else BattlegroundSpiritReleaserDB.Enabled = not BattlegroundSpiritReleaserDB.Enabled end
	if shouldPrint ~= nil and shouldPrint == true then
		print("BattlegroundSpiritReleaser is now "..(BattlegroundSpiritReleaserDB.Enabled and "enabled." or "disabled."))
	end
	if BattlegroundSpiritReleaserEnabledCheckButton == nil then return end
	BattlegroundSpiritReleaserEnabledCheckButton:SetChecked(BattlegroundSpiritReleaserDB.Enabled)
end

local function ToggleUseSoulstone(force, shouldPrint)
	if BattlegroundSpiritReleaserDB.UseSoulstone == nil then InitializeBattlegroundSpiritReleaserDB(BattlegroundSpiritReleaserDBDefaults) end
	if force ~= nil then BattlegroundSpiritReleaserDB.UseSoulstone = force else BattlegroundSpiritReleaserDB.UseSoulstone = not BattlegroundSpiritReleaserDB.UseSoulstone end
	if shouldPrint ~= nil and shouldPrint == true then
		print("BattlegroundSpiritReleaser: Using soulstone is now "..(BattlegroundSpiritReleaserDB.UseSoulstone and "enabled." or "disabled."))
	end
	if BattlegroundSpiritReleaserUseSoulstoneCheckButton == nil then return end
	BattlegroundSpiritReleaserUseSoulstoneCheckButton:SetChecked(BattlegroundSpiritReleaserDB.UseSoulstone)
end

local function SetSoulstoneDelay(delay, shouldPrint)
	if BattlegroundSpiritReleaserDB.SoulstoneDelay == nil then InitializeBattlegroundSpiritReleaserDB(BattlegroundSpiritReleaserDBDefaults) end
	local output = ""

	if delay == nil then
		output = "BattlegroundSpiritReleaser: The given soulstone delay was not a number. The delay before using soulstone is still "..(BattlegroundSpiritReleaserDB.SoulstoneDelay == 0 and "disabled" or (tostring(BattlegroundSpiritReleaserDB.SoulstoneDelay).." second"..(BattlegroundSpiritReleaserDB.SoulstoneDelay == 1 and "" or "s"))).."."
	else
		if delay < 0 then
			delay = 0
		elseif delay > maxSoulstoneDelay then
			delay = maxSoulstoneDelay
		end

		BattlegroundSpiritReleaserDB.SoulstoneDelay = delay

		output = "BattlegroundSpiritReleaser: The delay before using soulstone is now "..(delay == 0 and "disabled" or (tostring(delay).." second"..(delay == 1 and "" or "s"))).."."
	end

	BattlegroundSpiritReleaserSoulstoneDelayEditBox:SetText(tostring(BattlegroundSpiritReleaserDB.SoulstoneDelay))
	BattlegroundSpiritReleaserSoulstoneDelayEditBox:SetCursorPosition(0)
	local onValueChangedBackup = onValueChangedBackup or BattlegroundSpiritReleaserSoulstoneDelaySlider:GetScript("OnValueChanged")
	BattlegroundSpiritReleaserSoulstoneDelaySlider:SetScript("OnValueChanged", nil)
	--StaticPopupDialogs["DEATH"].timeout = delay
	BattlegroundSpiritReleaserSoulstoneDelaySlider:SetValue(BattlegroundSpiritReleaserDB.SoulstoneDelay)
	BattlegroundSpiritReleaserSoulstoneDelaySlider:SetScript("OnValueChanged", onValueChangedBackup)

	if shouldPrint ~= nil and shouldPrint == true then
		print(output)
	end
end

--GUI options menu
local optionsMenu = CreateFrame("Frame", "BattlegroundSpiritReleaserOptionsMenu", InterfaceOptionsFramePanelContainer)

local enabledCheckButton = CreateFrame("CheckButton", "BattlegroundSpiritReleaserEnabledCheckButton", optionsMenu, "OptionsCheckButtonTemplate")
enabledCheckButton:SetPoint("TOPLEFT", 16, -16)
enabledCheckButton:SetHitRectInsets(0, -240, 0, 0)
enabledCheckButton:SetScript("OnClick", function() ToggleBattlegroundSpiritReleaser(nil, false) end)
_G[enabledCheckButton:GetName() .. "Text"]:SetText("Release spirit as soon as possible")

local useSoulstoneCheckButton = CreateFrame("CheckButton", "BattlegroundSpiritReleaserUseSoulstoneCheckButton", optionsMenu, "OptionsCheckButtonTemplate")
useSoulstoneCheckButton:SetPoint("TOPLEFT", enabledCheckButton, "BOTTOMLEFT", 0, -8)
useSoulstoneCheckButton:SetScript("OnClick", function() ToggleUseSoulstone(nil, false) end)
useSoulstoneCheckButton:SetHitRectInsets(0, -450, 0, 0)
_G[useSoulstoneCheckButton:GetName() .. "Text"]:SetText("Use Soulstone if available")

local soulstoneDelayLabel = optionsMenu:CreateFontString("BattlegroundSpiritReleaserSoulstoneDelayLabel", nil, "GameFontNormalLeft")
soulstoneDelayLabel:SetPoint("TOPLEFT", useSoulstoneCheckButton, "BOTTOMLEFT", 0, -8)
soulstoneDelayLabel:SetNonSpaceWrap(true)
soulstoneDelayLabel:SetJustifyH("LEFT")
soulstoneDelayLabel:SetJustifyV("TOP")
soulstoneDelayLabel:SetText("Soulstone usage delay in seconds")

local soulstoneDelayEditBox = CreateFrame("EditBox", "BattlegroundSpiritReleaserSoulstoneDelayEditBox", optionsMenu, "InputBoxTemplate")
soulstoneDelayEditBox:SetPoint("TOPLEFT", soulstoneDelayLabel, "TOPRIGHT", 8, 0)
soulstoneDelayEditBox:SetWidth(40)
soulstoneDelayEditBox:SetHeight(soulstoneDelayLabel:GetHeight())
soulstoneDelayEditBox:SetAutoFocus(false)
soulstoneDelayEditBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
soulstoneDelayEditBox:SetScript("OnEditFocusLost", function(self) SetSoulstoneDelay(tonumber(self:GetText()), false) end)

local soulstoneDelaySlider = CreateFrame("Slider", "BattlegroundSpiritReleaserSoulstoneDelaySlider", optionsMenu, BackdropTemplateMixin and "BackdropTemplate")
soulstoneDelaySlider:SetPoint("TOPLEFT", soulstoneDelayEditBox, "TOPRIGHT", 8, 0)
soulstoneDelaySlider:SetWidth(300)
soulstoneDelaySlider:SetHeight(soulstoneDelayLabel:GetHeight())
soulstoneDelaySlider:SetOrientation("HORIZONTAL")
soulstoneDelaySlider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
soulstoneDelaySlider:SetBackdrop({
	bgFile = "Interface\\Buttons\\UI-SliderBar-Background", 
	edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
	tile = true, tileSize = 8, edgeSize = 8, 
	insets = { left = 3, right = 3, top = 6, bottom = 6 }})
soulstoneDelaySlider:SetValueStep(0.1)
soulstoneDelaySlider:SetMinMaxValues(0,maxSoulstoneDelay)
soulstoneDelaySlider:SetObeyStepOnDrag(true)
soulstoneDelaySlider:SetScript("OnMouseWheel", function(self, delta) SetSoulstoneDelay(delta > 0 and BattlegroundSpiritReleaserDB.SoulstoneDelay+0.05 or BattlegroundSpiritReleaserDB.SoulstoneDelay-0.05) end)
soulstoneDelaySlider:SetScript("OnValueChanged", function(self, value)
	value = floor((value*20)+0.5)/20
	BattlegroundSpiritReleaserDB.SoulstoneDelay = value
	BattlegroundSpiritReleaserSoulstoneDelayEditBox:SetText(tostring(value))
	BattlegroundSpiritReleaserSoulstoneDelayEditBox:SetCursorPosition(0)
end)

optionsMenu.name = "BattlegroundSpiritReleaser"
InterfaceOptions_AddCategory(optionsMenu)

--handle PLAYER_ENTERING_WORLD events for initializing GUI options menu widget states at the right time
--UI reload doesn't seem to fire ADDON_LOADED
optionsMenu:RegisterEvent("PLAYER_ENTERING_WORLD")
optionsMenu:RegisterEvent("ADDON_LOADED")
optionsMenu:SetScript("OnEvent", function (self, event, arg1, ...)
	if event == "PLAYER_ENTERING_WORLD" or arg1 == "BattlegroundSpiritReleaser" then
		InitializeBattlegroundSpiritReleaserDB(BattlegroundSpiritReleaserDBDefaults)
		BattlegroundSpiritReleaserEnabledCheckButton:SetChecked(BattlegroundSpiritReleaserDB.Enabled)
		BattlegroundSpiritReleaserUseSoulstoneCheckButton:SetChecked(BattlegroundSpiritReleaserDB.UseSoulstone)
		BattlegroundSpiritReleaserSoulstoneDelayEditBox:SetText(tostring(BattlegroundSpiritReleaserDB.SoulstoneDelay))
		BattlegroundSpiritReleaserSoulstoneDelayEditBox:SetCursorPosition(0)
		BattlegroundSpiritReleaserSoulstoneDelaySlider:SetValue(BattlegroundSpiritReleaserDB.SoulstoneDelay)

		optionsMenu:UnregisterAllEvents()
		optionsMenu:SetScript("OnEvent", nil)
	end
end)

--CLI options menu
_G["SLASH_BattlegroundSpiritReleaser1"] = "/BattlegroundSpiritReleaser"
_G["SLASH_BattlegroundSpiritReleaser2"] = "/battlegroundspiritreleaser"
_G["SLASH_BattlegroundSpiritReleaser3"] = "/bsr"
_G["SLASH_BattlegroundSpiritReleaser4"] = "/bgsr"
SlashCmdList["BattlegroundSpiritReleaser"] = function(msg)
	param1, param2, param3 = msg:match("([^%s,]*)[%s,]*([^%s,]*)[%s,]*([^%s,]*)[%s,]*")
	--print("Parameters passed were: "..tostring(param1).." "..tostring(param2).." "..tostring(param3))
	if param1 == "toggle" or param1 == "release" then
		ToggleBattlegroundSpiritReleaser(nil, true)
	elseif param1 == "enable" or param1 == "on" or param1 == "start" then
		ToggleBattlegroundSpiritReleaser(true, true)
	elseif param1 == "disable" or param1 == "off" or param1 == "stop" then
		ToggleBattlegroundSpiritReleaser(false, true)
	elseif param1 == "soulstonedelay" then
		SetSoulstoneDelay(tonumber(param2), true)
	elseif param1 == "soulstone" or param1 == "usesoulstone" then
		if param2 == "enable" or param2 == "on" or param2 == "start" then
			ToggleUseSoulstone(true, true)
		elseif (param2 == "disable" or param2 == "off" or param2 == "stop") then
			ToggleUseSoulstone(false, true)
		else
			ToggleUseSoulstone(nil, true)
		end
	elseif (param1 == "") then
		InterfaceOptionsFrame_OpenToCategory(optionsMenu)
	else
		print("BattlegroundSpiritReleaser: "..(param1 == "help" and "" or "Unrecognized command. ").."Recognized commands:")
		print("    '/bsr': GUI options menu")
		print("    '/bsr help': list CLI slash commands")
		print("    '/bsr toggle/[enable/on/start]/[disable/off/stop]': toggle whether BSR should release spirit")
		print("    '/bsr soulstone [enable/on/start]/[disable/off/stop]': toggle whether BSR should use soulstone")
		print("    '/bsr soulstonedelay <number>': set delay before BSR uses soulstone automatically, in seconds")
	end
end

--HasSoulstone was deprecated. Here's its functionality back if it's missing.
if (HasSoulstone == nil) then
	function HasSoulstone()
		local options = GetSortedSelfResurrectOptions()
		return options and options[1] and options[1].name
	end
end

--get current time when the death dialog appears to measure for delay
hooksecurefunc(StaticPopupDialogs["DEATH"],"OnShow",function(self)
	if InActiveBattlefield() and not IsActiveBattlefieldArena() then
		if HasSoulstone() and BattlegroundSpiritReleaserDB.UseSoulstone ~= nil and BattlegroundSpiritReleaserDB.UseSoulstone == true then
			BattlegroundSpiritReleaserSoulstoneDelayStartTime = GetTime()
		end
	end
end)

--the main functionality; post-hook for death StaticPopup
hooksecurefunc(StaticPopupDialogs["DEATH"],"OnUpdate",function(self)
	if InActiveBattlefield() and not IsActiveBattlefieldArena() then
		if HasSoulstone() and BattlegroundSpiritReleaserDB.UseSoulstone ~= nil and BattlegroundSpiritReleaserDB.UseSoulstone == true then
			if BattlegroundSpiritReleaserSoulstoneDelayStartTime ~= nil and self.button2:IsEnabled() and GetTime() >= BattlegroundSpiritReleaserSoulstoneDelayStartTime + BattlegroundSpiritReleaserDB.SoulstoneDelay then
				self.button2:Click()
				print("BattlegroundSpiritReleaser: Soulstone used"..(BattlegroundSpiritReleaserDB.SoulstoneDelay == 0 and "" or " after a delay of "..tostring(BattlegroundSpiritReleaserDB.SoulstoneDelay).." second"..(BattlegroundSpiritReleaserDB.SoulstoneDelay == 1 and "" or "s"))..". You can toggle this functionality with \"/bsr soulstone\".")
			end
		elseif self.button1:IsEnabled() and BattlegroundSpiritReleaserDB.Enabled ~= nil and BattlegroundSpiritReleaserDB.Enabled == true then
			self.button1:Click()
		end
	end
end)