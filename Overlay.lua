local _, NS = ...
local Addon = NS.Addon

local Overlay = {}
NS.Overlay = Overlay

local overlays = setmetatable({}, { __mode = "k" })

local function GetBagAndSlot(button)
    local slot = button:GetID()
    local bag

    if type(button.GetBagID) == "function" then
        bag = button:GetBagID()
    elseif button:GetParent() then
        bag = button:GetParent():GetID()
    end

    return bag, slot
end

local function GetOrCreateOverlay(button)
    local existing = overlays[button]
    if existing then
        return existing
    end

    local frame = CreateFrame("Frame", nil, button)
    frame:SetAllPoints(button)
    frame:SetFrameLevel(button:GetFrameLevel() + 5)
    frame:EnableMouse(false)

    local glow = frame:CreateTexture(nil, "OVERLAY")
    glow:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    glow:SetBlendMode("ADD")
    glow:SetVertexColor(0.10, 0.75, 1.00, 0.95)
    glow:SetPoint("CENTER")
    glow:SetSize(62, 62)

    local icon = frame:CreateTexture(nil, "OVERLAY")
    icon:SetTexture("Interface\\Icons\\INV_Misc_Gem_BloodGem_01")
    icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
    icon:SetSize(15, 15)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    frame.glow = glow
    frame.icon = icon
    frame:Hide()
    overlays[button] = frame
    return frame
end

function Overlay:UpdateButton(button)
    if not button then
        return
    end

    local overlay = GetOrCreateOverlay(button)
    if not Addon.db or not Addon.db.profile.enabled or not Addon.db.profile.showOverlays then
        overlay:Hide()
        return
    end

    local bag, slot = GetBagAndSlot(button)
    if bag ~= nil and slot and NS.TargetIndex[NS.Rules.MakeTargetKey(bag, slot)] then
        overlay:Show()
    else
        overlay:Hide()
    end
end

function Overlay:RefreshContainerFrame(frame)
    if not frame or not frame.GetName then
        return
    end

    local name = frame:GetName()
    if not name then
        return
    end

    local size = tonumber(frame.size) or 0
    for index = 1, size do
        local button = _G[name .. "Item" .. index]
        if button then
            self:UpdateButton(button)
        end
    end
end

function Overlay:RefreshVisible()
    local count = tonumber(NUM_CONTAINER_FRAMES) or 13
    for index = 1, count do
        local frame = _G["ContainerFrame" .. index]
        if frame and frame:IsShown() then
            self:RefreshContainerFrame(frame)
        end
    end
end

function Overlay:Initialize()
    if type(ContainerFrame_Update) == "function" and type(hooksecurefunc) == "function" then
        hooksecurefunc("ContainerFrame_Update", function(frame)
            Overlay:RefreshContainerFrame(frame)
        end)
    end
end
