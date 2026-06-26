local _, NS = ...
local Addon = NS.Addon
local L = NS.L

local eventFrame
local loginHandled = false

local function IsSupportedClient()
    if WOW_PROJECT_MISTS_CLASSIC and WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC then
        return true
    end

    if WOW_PROJECT_BURNING_CRUSADE_CLASSIC then
        return WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
    end

    local interfaceVersion = select(4, GetBuildInfo())
    return interfaceVersion == 20505 or (interfaceVersion >= 50500 and interfaceVersion < 50600)
end

function Addon:OnTargetsChanged()
    if NS.Overlay then
        NS.Overlay:RefreshVisible()
    end
    if NS.ActionButton then
        NS.Action:Refresh()
    end
end

function Addon:HandleSlash(input)
    local command = tostring(input or ""):match("^%s*(.-)%s*$"):lower()
    if command == "config" or command == "options" or command == "" then
        NS.Config:Open()
    elseif command == "rescan" then
        NS.Action:Disarm(L.ACTION_STALE)
        NS.Scanner:ScheduleScan(0.05)
        self:Print(L.MSG_RESCAN)
    elseif command == "show" then
        NS.Action:SetPanelVisible(true)
    elseif command == "hide" then
        NS.Action:SetPanelVisible(false)
    elseif command == "toggle" then
        NS.Action:TogglePanelVisible()
    else
        self:Print(L.MSG_HELP)
    end
end

function Addon:HandlePlayerLogin()
    if loginHandled then
        return
    end
    loginHandled = true

    NS.Scanner:PrimeMaterialCache()
    NS.Scanner:ScheduleScan(0.05)
    if not NS.IsSupportedClient then
        self:Print(L.MSG_UNSUPPORTED)
    end
end

function Addon:HandleEvent(event, ...)
    if event == "PLAYER_LOGIN" then
        self:HandlePlayerLogin()
    elseif event == "BAG_UPDATE_DELAYED" then
        NS.Action:Disarm(L.ACTION_STALE)
        NS.Action:HandleInventoryChanged()
        NS.Scanner:ScheduleScan(0.12)
    elseif event == "ITEM_LOCK_CHANGED" then
        NS.Action:Disarm(L.ACTION_STALE)
        NS.Scanner:ScheduleScan(0.12)
    elseif event == "GET_ITEM_INFO_RECEIVED" then
        NS.Scanner:ScheduleScan(0.12)
    elseif event == "SPELLS_CHANGED" then
        NS.Action:Refresh()
    elseif event == "PLAYER_REGEN_DISABLED" then
        NS.Action:Refresh()
    elseif event == "PLAYER_REGEN_ENABLED" then
        NS.Scanner:ScheduleScan(0.05)
    elseif event == "LOOT_OPENED" then
        NS.Action:SetLootOpen(true)
    elseif event == "LOOT_CLOSED" then
        NS.Action:SetLootOpen(false)
        NS.Scanner:ScheduleScan(0.05)
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, _, spellID = ...
        NS.Action:HandleSpellSucceeded(unit, spellID)
    elseif event == "UNIT_SPELLCAST_FAILED"
        or event == "UNIT_SPELLCAST_FAILED_QUIET"
        or event == "UNIT_SPELLCAST_INTERRUPTED" then
        local unit, _, spellID = ...
        NS.Action:HandleSpellFailed(unit, spellID)
    end
end

function Addon:RegisterEvents()
    eventFrame = CreateFrame("Frame")
    local events = {
        "PLAYER_LOGIN",
        "BAG_UPDATE_DELAYED",
        "ITEM_LOCK_CHANGED",
        "GET_ITEM_INFO_RECEIVED",
        "SPELLS_CHANGED",
        "PLAYER_REGEN_DISABLED",
        "PLAYER_REGEN_ENABLED",
        "LOOT_OPENED",
        "LOOT_CLOSED",
        "UNIT_SPELLCAST_SUCCEEDED",
        "UNIT_SPELLCAST_FAILED",
        "UNIT_SPELLCAST_FAILED_QUIET",
        "UNIT_SPELLCAST_INTERRUPTED",
    }
    for index = 1, #events do
        eventFrame:RegisterEvent(events[index])
    end
    eventFrame:SetScript("OnEvent", function(_, event, ...)
        Addon:HandleEvent(event, ...)
    end)
end

function Addon:OnInitialize()
    NS.IsSupportedClient = IsSupportedClient()
    NS.Config:InitializeDatabase()
    NS.Config:RegisterOptions()
    NS.Tooltip:Initialize()
    NS.Overlay:Initialize()
    NS.Action:Initialize()
    NS.MinimapButton:Initialize()
    self:RegisterEvents()
    self:RegisterChatCommand("safeprospecting", "HandleSlash")
    self:RegisterChatCommand("sp", "HandleSlash")
end

function Addon:OnEnable()
    if type(IsLoggedIn) == "function" and IsLoggedIn() then
        self:HandlePlayerLogin()
    end
end
