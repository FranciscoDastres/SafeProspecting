local _, NS = ...
local Addon = NS.Addon
local L = NS.L

local Tooltip = {}
NS.Tooltip = Tooltip

local function GetItemInfo(item)
    if C_Item and C_Item.GetItemInfo then
        return C_Item.GetItemInfo(item)
    end
    return _G.GetItemInfo(item)
end

local function RequestItem(item)
    local itemID = type(item) == "number" and item or tonumber(tostring(item or ""):match("item:(%d+)"))
    if itemID and C_Item and C_Item.RequestLoadItemDataByID then
        C_Item.RequestLoadItemDataByID(itemID)
    elseif type(_G.GetItemInfo) == "function" then
        _G.GetItemInfo(item)
    end
end

local function IsForbiddenTooltip(tooltip)
    if not tooltip or type(tooltip.IsForbidden) ~= "function" then
        return false
    end

    local ok, forbidden = pcall(tooltip.IsForbidden, tooltip)
    return ok and forbidden == true
end

local function GetTooltipItemLink(tooltip, data)
    if type(data) == "table" and data.hyperlink then
        return data.hyperlink
    end

    if tooltip and type(tooltip.GetItem) == "function" then
        local ok, _, itemLink = pcall(tooltip.GetItem, tooltip)
        if ok then
            return itemLink
        end
    end

    return nil
end

local function GetTooltipItemID(itemLink, data)
    if type(data) == "table" and type(data.id) == "number" then
        return data.id
    end
    return tonumber(tostring(itemLink or ""):match("item:(%d+)"))
end

local function GetItemIcon(itemID)
    if C_Item and C_Item.GetItemIconByID then
        return C_Item.GetItemIconByID(itemID)
    end
    if type(_G.GetItemIcon) == "function" then
        return _G.GetItemIcon(itemID)
    end
    local _, _, _, _, _, _, _, _, _, texture = GetItemInfo(itemID)
    return texture
end

local function FormatQuantity(minimum, maximum)
    if minimum == maximum then
        return tostring(minimum)
    end
    return tostring(minimum) .. "-" .. tostring(maximum)
end

local function FormatChance(chance)
    if math.floor(chance) == chance then
        return tostring(chance)
    end
    return (string.format("%.2f", chance):gsub("0+$", ""):gsub("%.$", ""))
end

function Tooltip:AddOutcomeLines(tooltip, outcomes, requiredSkill)
    if not tooltip or not outcomes or #outcomes == 0 or IsForbiddenTooltip(tooltip) then
        return false
    end

    tooltip:AddLine(" ")
    tooltip:AddLine(L.PREDICTION_HEADER, 0.35, 0.85, 1.00)
    if requiredSkill then
        tooltip:AddLine(string.format(L.PREDICTION_SKILL, requiredSkill), 0.60, 0.80, 1.00)
    end

    for index = 1, #outcomes do
        local result = outcomes[index]
        local materialName, materialLink = GetItemInfo(result.itemID)
        local icon = GetItemIcon(result.itemID)
        local displayName = materialLink or materialName or ("item:" .. tostring(result.itemID))
        if icon then
            displayName = "|T" .. tostring(icon) .. ":14:14:0:0|t " .. displayName
        end
        tooltip:AddLine(string.format(
            L.PREDICTION_LINE,
            displayName,
            FormatQuantity(result.minQuantity, result.maxQuantity),
            FormatChance(result.chance)
        ), 0.85, 0.85, 0.85)
    end

    return true
end

function Tooltip:AddPredictions(tooltip, data)
    if not Addon.db or not Addon.db.profile or not Addon.db.profile.showTooltips or IsForbiddenTooltip(tooltip) then
        return
    end

    local itemLink = GetTooltipItemLink(tooltip, data)
    local itemID = GetTooltipItemID(itemLink, data)
    if not itemID or tooltip.__SafeProspectingItemID == itemID then
        return
    end

    local ore = NS.Rules.GetOreRule(itemID)
    if not ore then
        if itemLink then
            RequestItem(itemLink)
        end
        return
    end

    tooltip.__SafeProspectingItemID = itemID
    if self:AddOutcomeLines(tooltip, ore.outcomes, ore.requiredSkill) then
        tooltip:AddLine(L.PREDICTION_FOOTER, 0.65, 0.65, 0.65, true)
        tooltip:Show()
    end
end

function Tooltip:ClearMarker(tooltip)
    tooltip.__SafeProspectingItemID = nil
end

function Tooltip:Initialize()
    local function callback(tooltip, data)
        Tooltip:AddPredictions(tooltip, data)
    end

    if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall
        and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Item then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, callback)
    else
        if GameTooltip then
            GameTooltip:HookScript("OnTooltipSetItem", callback)
        end
        if ItemRefTooltip then
            ItemRefTooltip:HookScript("OnTooltipSetItem", callback)
        end
    end

    if GameTooltip then
        GameTooltip:HookScript("OnTooltipCleared", function(tip) Tooltip:ClearMarker(tip) end)
    end
    if ItemRefTooltip then
        ItemRefTooltip:HookScript("OnTooltipCleared", function(tip) Tooltip:ClearMarker(tip) end)
    end
end
