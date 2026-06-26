local _, NS = ...
local Addon = NS.Addon
local L = NS.L

local Config = {}
NS.Config = Config

local defaults = {
    profile = {
        enabled = true,
        protectedItemIDs = {},
        showTooltips = true,
        showOverlays = true,
        showMinimapButton = true,
        actionButtonVisible = true,
        buttonPosition = {},
    },
}

local function NotifyChanged()
    if NS.ActionButton then
        NS.Action:Disarm(L.ACTION_STALE)
    end
    NS.Scanner:ScheduleScan(0.05)
end

local function SerializeProtectedIDs()
    local ids = {}
    for itemID, protected in pairs(Addon.db.profile.protectedItemIDs or {}) do
        if protected then
            ids[#ids + 1] = tonumber(itemID)
        end
    end
    table.sort(ids)

    for index = 1, #ids do
        ids[index] = tostring(ids[index])
    end
    return table.concat(ids, ", ")
end

local function ParseProtectedIDs(value)
    local ids = {}
    for token in tostring(value or ""):gmatch("[^,%s;]+") do
        local itemID = tonumber(token:match("item:(%d+)")) or tonumber(token)
        if itemID and itemID > 0 then
            ids[itemID] = true
        end
    end
    Addon.db.profile.protectedItemIDs = ids
    NotifyChanged()
end

function Config:InitializeDatabase()
    Addon.db = LibStub("AceDB-3.0"):New("SafeProspectingDB", defaults, true)
end

function Config:RegisterOptions()
    local options = {
        type = "group",
        name = L.CONFIG_NAME,
        args = {
            description = {
                type = "description",
                name = L.ADDON_DESCRIPTION,
                order = 1,
            },
            enabled = {
                type = "toggle",
                name = L.CONFIG_ENABLED,
                desc = L.CONFIG_ENABLED_DESC,
                order = 10,
                get = function() return Addon.db.profile.enabled end,
                set = function(_, value)
                    Addon.db.profile.enabled = value
                    NotifyChanged()
                end,
            },
            tooltips = {
                type = "toggle",
                name = L.CONFIG_TOOLTIPS,
                order = 40,
                get = function() return Addon.db.profile.showTooltips end,
                set = function(_, value) Addon.db.profile.showTooltips = value end,
            },
            overlays = {
                type = "toggle",
                name = L.CONFIG_OVERLAYS,
                order = 41,
                get = function() return Addon.db.profile.showOverlays end,
                set = function(_, value)
                    Addon.db.profile.showOverlays = value
                    NS.Overlay:RefreshVisible()
                end,
            },
            actionButton = {
                type = "toggle",
                name = L.CONFIG_ACTION_BUTTON,
                desc = L.CONFIG_ACTION_BUTTON_DESC,
                order = 42,
                get = function() return Addon.db.profile.actionButtonVisible ~= false end,
                set = function(_, value)
                    NS.Action:SetPanelVisible(value)
                end,
            },
            minimapButton = {
                type = "toggle",
                name = L.CONFIG_MINIMAP_BUTTON,
                desc = L.CONFIG_MINIMAP_BUTTON_DESC,
                order = 43,
                get = function() return Addon.db.profile.showMinimapButton ~= false end,
                set = function(_, value)
                    Addon.db.profile.showMinimapButton = value
                    if NS.MinimapButton then
                        NS.MinimapButton:Refresh()
                    end
                end,
            },
            protected = {
                type = "input",
                name = L.CONFIG_PROTECTED,
                desc = L.CONFIG_PROTECTED_DESC,
                order = 50,
                multiline = 4,
                width = "full",
                get = SerializeProtectedIDs,
                set = function(_, value) ParseProtectedIDs(value) end,
            },
            resetPosition = {
                type = "execute",
                name = L.CONFIG_RESET_POSITION,
                order = 60,
                func = function() NS.Action:ResetPosition() end,
            },
        },
    }

    local profileOptions = LibStub("AceDBOptions-3.0"):GetOptionsTable(Addon.db)
    profileOptions.name = L.CONFIG_PROFILES
    profileOptions.order = 100
    options.args.profiles = profileOptions

    LibStub("AceConfig-3.0"):RegisterOptionsTable("SafeProspecting", options)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SafeProspecting", L.CONFIG_NAME)

    local function ProfileChanged()
        NotifyChanged()
        if NS.ActionButton then
            NS.Action:Refresh()
        end
        if NS.MinimapButton then
            NS.MinimapButton:Refresh()
        end
    end
    Addon.db.RegisterCallback(Addon, "OnProfileChanged", ProfileChanged)
    Addon.db.RegisterCallback(Addon, "OnProfileCopied", ProfileChanged)
    Addon.db.RegisterCallback(Addon, "OnProfileReset", ProfileChanged)
end

function Config:Open()
    LibStub("AceConfigDialog-3.0"):Open("SafeProspecting")
end
