local _, NS = ...
local Addon = NS.Addon
local L = NS.L

local MinimapButton = {}
NS.MinimapButton = MinimapButton

local button

local function IsShownInProfile()
    return not Addon.db or Addon.db.profile.showMinimapButton ~= false
end

local function GetPanelVisible()
    return NS.Action and NS.Action:IsPanelVisible()
end

local function SetTooltip(owner)
    if not GameTooltip then
        return
    end

    GameTooltip:SetOwner(owner, "ANCHOR_LEFT")
    GameTooltip:AddLine(L.MINIMAP_TOOLTIP_TITLE, 0.35, 0.85, 1.00)
    if GetPanelVisible() then
        GameTooltip:AddLine(L.MINIMAP_TOOLTIP_LEFT_HIDE, 1, 1, 1)
    else
        GameTooltip:AddLine(L.MINIMAP_TOOLTIP_LEFT_SHOW, 1, 1, 1)
    end
    GameTooltip:AddLine(L.MINIMAP_TOOLTIP_RIGHT, 0.85, 0.85, 0.85)
    GameTooltip:Show()
end

function MinimapButton:Refresh()
    if not button then
        return
    end

    if not IsShownInProfile() then
        button:Hide()
        return
    end

    button:Show()
    if button.icon then
        if GetPanelVisible() then
            button.icon:SetDesaturated(false)
            button.icon:SetVertexColor(1, 1, 1)
        else
            button.icon:SetDesaturated(true)
            button.icon:SetVertexColor(0.75, 0.75, 0.75)
        end
    end
end

function MinimapButton:Initialize()
    if button or not Minimap then
        return
    end

    button = CreateFrame("Button", "SafeProspectingMinimapButton", Minimap)
    button:SetSize(32, 32)
    button:SetFrameStrata("MEDIUM")
    button:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", -2, -2)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    button.icon = button:CreateTexture(nil, "BACKGROUND")
    button.icon:SetSize(20, 20)
    button.icon:SetPoint("CENTER", 1, 1)
    button.icon:SetTexture("Interface\\Icons\\INV_Misc_Gem_BloodGem_01")
    button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetSize(54, 54)
    border:SetPoint("TOPLEFT", 0, 0)
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    button:SetScript("OnClick", function(_, mouseButton)
        if mouseButton == "RightButton" then
            NS.Config:Open()
        elseif NS.Action then
            NS.Action:TogglePanelVisible()
        end
    end)
    button:SetScript("OnEnter", function(self)
        SetTooltip(self)
    end)
    button:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)

    self:Refresh()
end
