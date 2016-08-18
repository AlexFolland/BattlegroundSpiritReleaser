--default values for options saved between sessions
BattlegroundSpiritReleaserDBDefaults = {
    Enabled = true,
    UseSoulstone = true
}

--initialize table for storing saved variables
if (not BattlegroundSpiritReleaserDB) then BattlegroundSpiritReleaserDB = {} end

--initialize missing saved variables with default values
for k,v in pairs(BattlegroundSpiritReleaserDBDefaults) do
    if BattlegroundSpiritReleaserDB[k] == nil then
        BattlegroundSpiritReleaserDB[k] = BattlegroundSpiritReleaserDBDefaults[k]
    end
end

--option setters
function ToggleBattlegroundSpiritReleaser(force, shouldPrint)
    if BattlegroundSpiritReleaserDB.Enabled == nil then return end
    if force ~= nil then BattlegroundSpiritReleaserDB.Enabled = force else BattlegroundSpiritReleaserDB.Enabled = not BattlegroundSpiritReleaserDB.Enabled end
    if shouldPrint ~= nil and shouldPrint == true then
        print("BattlegroundSpiritReleaser is now "..(BattlegroundSpiritReleaserDB.Enabled and "enabled." or "disabled."))
    end
    if BattlegroundSpiritReleaserEnabledCheckButton == nil then return end
    BattlegroundSpiritReleaserEnabledCheckButton:SetChecked(BattlegroundSpiritReleaserDB.Enabled)
end

function ToggleUseSoulstone(force, shouldPrint)
    if BattlegroundSpiritReleaserDB.UseSoulstone == nil then return end
    if force ~= nil then BattlegroundSpiritReleaserDB.UseSoulstone = force else BattlegroundSpiritReleaserDB.UseSoulstone = not BattlegroundSpiritReleaserDB.UseSoulstone end
    if shouldPrint ~= nil and shouldPrint == true then
        print("BattlegroundSpiritReleaser: Using soulstone is now "..(BattlegroundSpiritReleaserDB.UseSoulstone and "enabled." or "disabled."))
    end
    if BattlegroundSpiritReleaserUseSoulstoneCheckButton == nil then return end
    BattlegroundSpiritReleaserUseSoulstoneCheckButton:SetChecked(BattlegroundSpiritReleaserDB.UseSoulstone)
end

--GUI options menu
local optionsMenu = CreateFrame("Frame", "BattlegroundSpiritReleaserOptionsMenu", UIParent)

local enabledCheckButton = CreateFrame("CheckButton", "BattlegroundSpiritReleaserEnabledCheckButton", optionsMenu, "OptionsCheckButtonTemplate")
enabledCheckButton:SetScript("OnClick", function() ToggleBattlegroundSpiritReleaser(nil, false) end)
enabledCheckButton:SetPoint("TOPLEFT", 16, -16)
enabledCheckButton:SetHitRectInsets(0, -240, 0, 0)
_G[enabledCheckButton:GetName() .. "Text"]:SetText("Release spirit as soon as possible")

local useSoulstoneCheckButton = CreateFrame("CheckButton", "BattlegroundSpiritReleaserUseSoulstoneCheckButton", optionsMenu, "OptionsCheckButtonTemplate")
useSoulstoneCheckButton:SetScript("OnClick", function() ToggleUseSoulstone(nil, false) end)
useSoulstoneCheckButton:SetPoint("TOPLEFT", 16, -16)
useSoulstoneCheckButton:SetHitRectInsets(0, -450, 0, 0)
_G[useSoulstoneCheckButton:GetName() .. "Text"]:SetText("Use Soulstone as soon as possible if available")
useSoulstoneCheckButton:SetPoint("TOPLEFT", enabledCheckButton, "BOTTOMLEFT", 0, -8)

optionsMenu.name = "BattlegroundSpiritReleaser"
InterfaceOptions_AddCategory(optionsMenu)

--handle ADDON_LOADED event for initializing GUI options menu checkbox states at the right time
optionsMenu:RegisterEvent("ADDON_LOADED")
optionsMenu:SetScript("OnEvent", function (this, event, arg1, ...)
    if arg1 == "BattlegroundSpiritReleaser" then
        BattlegroundSpiritReleaserEnabledCheckButton:SetChecked(BattlegroundSpiritReleaserDB.Enabled)
        BattlegroundSpiritReleaserUseSoulstoneCheckButton:SetChecked(BattlegroundSpiritReleaserDB.UseSoulstone)
        optionsMenu:UnregisterEvent(event)
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
    if (not param1) then param1 = "(nil)" end
    if (not param2) then param2 = "(nil)" end
    if (not param3) then param3 = "(nil)" end
    if (param1 == "toggle" or param1 == "release") then
        ToggleBattlegroundSpiritReleaser(nil, true)
    elseif (param1 == "enable" or param1 == "on" or param1 == "start") then
        ToggleBattlegroundSpiritReleaser(true, true)
    elseif (param1 == "disable" or param1 == "off" or param1 == "stop") then
        ToggleBattlegroundSpiritReleaser(false, true)
    elseif (param1 == "soulstone" or param1 == "usesoulstone") then
        if (param2 == "enable" or param2 == "on" or param2 == "start") then
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
    end
end

--the main functionality; post-hook for death StaticPopup
hooksecurefunc(StaticPopupDialogs["DEATH"],"OnUpdate",function(self)
    if InActiveBattlefield() and not IsActiveBattlefieldArena() then
        if HasSoulstone() and BattlegroundSpiritReleaserDB.UseSoulstone ~= nil and BattlegroundSpiritReleaserDB.UseSoulstone == true then
            if self.button2:IsEnabled() then
                self.button2:Click()
                print("BattlegroundSpiritReleaser: Soulstone used. You can toggle this functionality with \"/bsr soulstone\".")
            end
        elseif self.button1:IsEnabled() and BattlegroundSpiritReleaserDB.Enabled ~= nil and BattlegroundSpiritReleaserDB.Enabled == true then
            self.button1:Click()
        end
    end
end)