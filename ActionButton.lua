local _, NS = ...
local Addon = NS.Addon
local L = NS.L

local Action = {}
NS.Action = Action

local button
local hideButton
local armedTarget
local state = NS.ActionState:New()
local lootOpen = false

local function SetStatus(text, red, green, blue)
    if not button then
        return
    end
    button.status:SetText(text or "")
    button.status:SetTextColor(red or 0.75, green or 0.75, blue or 0.75)
end

local function ClearSecureAttributes()
    if not button or InCombatLockdown() then
        return false
    end
    button:SetAttribute("type", nil)
    button:SetAttribute("spell", nil)
    button:SetAttribute("target-bag", nil)
    button:SetAttribute("target-slot", nil)
    button:SetAttribute("target-item", nil)
    return true
end

local function SavePosition()
    if not Addon.db or not button then
        return
    end
    local point, _, relativePoint, x, y = button:GetPoint(1)
    Addon.db.profile.buttonPosition = {
        point = point,
        relativePoint = relativePoint,
        x = x,
        y = y,
    }
end

local function ShowPanel()
    if button then
        button:Show()
    end
    if hideButton then
        hideButton:Show()
    end
end

local function HidePanel()
    if hideButton then
        hideButton:Hide()
    end
    if button then
        button:Hide()
    end
end

function Action:HasProspecting()
    if C_SpellBook and C_SpellBook.IsSpellKnown then
        return C_SpellBook.IsSpellKnown(NS.PROSPECTING_SPELL_ID)
    end
    if type(IsSpellKnown) == "function" then
        return IsSpellKnown(NS.PROSPECTING_SPELL_ID)
    end
    if type(IsPlayerSpell) == "function" then
        return IsPlayerSpell(NS.PROSPECTING_SPELL_ID)
    end
    return false
end

function Action:IsPanelVisible()
    return Addon.db and Addon.db.profile.actionButtonVisible ~= false
end

function Action:SetPanelVisible(visible)
    if not Addon.db then
        return false
    end
    if InCombatLockdown() then
        Addon:Print(L.MSG_PANEL_COMBAT)
        return false
    end

    Addon.db.profile.actionButtonVisible = visible == true
    if Addon.db.profile.actionButtonVisible then
        ShowPanel()
        self:Refresh()
    else
        self:Disarm()
        HidePanel()
    end

    if NS.MinimapButton then
        NS.MinimapButton:Refresh()
    end
    return true
end

function Action:TogglePanelVisible()
    return self:SetPanelVisible(not self:IsPanelVisible())
end

function Action:Disarm(status)
    armedTarget = nil
    if button then
        button:Disable()
        button.icon:SetDesaturated(true)
        ClearSecureAttributes()
        if status then
            SetStatus(status)
        end
    end
end

function Action:Arm(target)
    if not target or InCombatLockdown() then
        return false
    end
    if not NS.Scanner:IsTargetPresent(target) then
        self:Disarm(L.ACTION_STALE)
        NS.Scanner:ScheduleScan(0.05)
        return false
    end

    ClearSecureAttributes()
    button:SetAttribute("spell", NS.PROSPECTING_SPELL_ID)
    button:SetAttribute("target-bag", target.bag)
    button:SetAttribute("target-slot", target.slot)
    button:SetAttribute("type", "spell")
    armedTarget = target
    button:Enable()
    button.icon:SetDesaturated(false)
    return true
end

function Action:Refresh()
    if not button or not Addon.db then
        return
    end

    local targets = NS.TargetList
    button.count:SetText(string.format(L.ACTION_COUNT, #targets))

    if not self:IsPanelVisible() then
        self:Disarm()
        if not InCombatLockdown() then
            HidePanel()
        end
        return
    end
    ShowPanel()

    if not Addon.db.profile.enabled then
        self:Disarm(L.ACTION_DISABLED)
        if not InCombatLockdown() then
            HidePanel()
        end
        return
    end

    if not NS.IsSupportedClient then
        self:Disarm(L.ACTION_UNSUPPORTED)
        button.name:SetText("SafeProspecting")
        button.icon:SetTexture("Interface\\Icons\\INV_Misc_Gem_BloodGem_01")
        return
    end
    if InCombatLockdown() then
        button:Disable()
        button.icon:SetDesaturated(true)
        SetStatus(L.ACTION_COMBAT)
        return
    end
    if state.pending then
        self:Disarm(L.ACTION_PENDING)
        return
    end
    if lootOpen then
        self:Disarm(L.ACTION_LOOT)
        return
    end
    if not self:HasProspecting() then
        self:Disarm(L.ACTION_NO_PROFESSION)
        button.name:SetText("SafeProspecting")
        button.icon:SetTexture("Interface\\Icons\\INV_Misc_Gem_BloodGem_01")
        return
    end
    if not NS.Scanner:HasFreeBagSlot() then
        self:Disarm(L.ACTION_FULL_BAGS)
        return
    end

    local target = targets[1]
    if not target then
        self:Disarm(L.ACTION_EMPTY)
        button.name:SetText("SafeProspecting")
        button.icon:SetTexture("Interface\\Icons\\INV_Misc_Gem_BloodGem_01")
        return
    end
    if NS.Scanner:IsTargetLocked(target) then
        self:Disarm(L.ACTION_STALE)
        return
    end

    button.name:SetText(target.itemLink or target.itemName)
    button.icon:SetTexture(target.texture or "Interface\\Icons\\INV_Misc_Gem_BloodGem_01")
    SetStatus(string.format(L.ACTION_READY_DETAIL, target.stackCount, target.requiredSkill), 0.70, 1.00, 0.70)
    self:Arm(target)
end

function Action:BeginPending()
    if not armedTarget or state.pending then
        return
    end

    local thisPending = state:Begin(armedTarget, GetTime())
    button:Disable()
    SetStatus(L.ACTION_PENDING, 1.00, 0.82, 0.25)

    C_Timer.After(8, function()
        if state:IsCurrent(thisPending) then
            state:Clear()
            Addon:Print(L.MSG_TIMEOUT)
            NS.Scanner:ScheduleScan(0.05)
        end
    end)
end

function Action:FinishSuccess()
    if not state.pending then
        return
    end
    local completed = state:Clear().target
    Addon:Print(string.format(L.MSG_SUCCESS, completed.itemLink or completed.itemName))
    NS.Scanner:ScheduleScan(0.05)
end

function Action:HandleSpellSucceeded(unit, spellID)
    if not state.pending or unit ~= "player" or spellID ~= NS.PROSPECTING_SPELL_ID then
        return
    end
    if NS.Scanner:DidTargetChange(state.pending.target) then
        state:MarkInventoryChanged()
    end
    if state:MarkSpellSucceeded() then
        self:FinishSuccess()
    end
end

function Action:HandleSpellFailed(unit, spellID)
    if not state.pending or unit ~= "player" or spellID ~= NS.PROSPECTING_SPELL_ID then
        return
    end
    state:Clear()
    Addon:Print(L.MSG_FAILED)
    NS.Scanner:ScheduleScan(0.05)
end

function Action:HandleInventoryChanged()
    if state.pending and NS.Scanner:DidTargetChange(state.pending.target) then
        if state:MarkInventoryChanged() then
            self:FinishSuccess()
        end
    end
end

function Action:SetLootOpen(isOpen)
    lootOpen = isOpen == true
    self:Refresh()
end

function Action:ResetPosition()
    if not button then
        return
    end
    button:ClearAllPoints()
    button:SetPoint("CENTER", UIParent, "CENTER", 0, -180)
    SavePosition()
end

function Action:Initialize()
    button = CreateFrame("Button", "SafeProspectingActionButton", UIParent, "SecureActionButtonTemplate,BackdropTemplate")
    NS.ActionButton = button
    button:SetSize(230, 62)
    button:SetClampedToScreen(true)
    button:SetAttribute("useOnKeyDown", false)
    button:RegisterForClicks("LeftButtonUp")
    button:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 14,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    button:SetBackdropColor(0.04, 0.05, 0.06, 0.95)
    button:SetBackdropBorderColor(0.15, 0.65, 0.95, 1.00)

    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetSize(42, 42)
    button.icon:SetPoint("LEFT", 10, 0)
    button.icon:SetTexture("Interface\\Icons\\INV_Misc_Gem_BloodGem_01")
    button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    button.name = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.name:SetPoint("TOPLEFT", button.icon, "TOPRIGHT", 9, -2)
    button.name:SetPoint("RIGHT", -10, 0)
    button.name:SetJustifyH("LEFT")
    button.name:SetText("SafeProspecting")

    button.status = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    button.status:SetPoint("BOTTOMLEFT", button.icon, "BOTTOMRIGHT", 9, 2)
    button.status:SetPoint("RIGHT", -10, 0)
    button.status:SetJustifyH("LEFT")

    button.count = button:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    button.count:SetPoint("TOPRIGHT", button, "BOTTOMRIGHT", -4, -2)

    local moveHandle = CreateFrame("Frame", nil, button)
    moveHandle:SetSize(58, 15)
    moveHandle:SetPoint("BOTTOM", button, "TOP", 0, -2)
    moveHandle:EnableMouse(true)
    moveHandle:RegisterForDrag("LeftButton")
    moveHandle.text = moveHandle:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    moveHandle.text:SetAllPoints()
    moveHandle.text:SetText(L.MOVE_HANDLE)
    moveHandle:SetScript("OnDragStart", function()
        if not InCombatLockdown() then
            button:StartMoving()
        end
    end)
    moveHandle:SetScript("OnDragStop", function()
        button:StopMovingOrSizing()
        SavePosition()
    end)
    button:SetMovable(true)

    hideButton = CreateFrame("Button", "SafeProspectingActionHideButton", UIParent, "UIPanelCloseButton")
    hideButton:SetSize(20, 20)
    hideButton:SetPoint("TOPRIGHT", button, "TOPRIGHT", 8, 8)
    hideButton:SetFrameStrata(button:GetFrameStrata())
    hideButton:SetFrameLevel(button:GetFrameLevel() + 5)
    hideButton:SetScript("OnClick", function()
        Action:SetPanelVisible(false)
    end)
    hideButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine(L.ACTION_HIDE, 1, 1, 1)
        GameTooltip:Show()
    end)
    hideButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    button:SetScript("PostClick", function()
        Action:BeginPending()
    end)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine(L.ACTION_TOOLTIP_TITLE, 0.35, 0.85, 1.00)
        GameTooltip:AddLine(L.ACTION_TOOLTIP_BODY, 1, 1, 1, true)
        if Addon.db.profile.showTooltips and armedTarget and armedTarget.outcomes and NS.Tooltip then
            NS.Tooltip:AddOutcomeLines(GameTooltip, armedTarget.outcomes, armedTarget.requiredSkill)
        end
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    local position = Addon.db.profile.buttonPosition
    if position and position.point then
        button:SetPoint(position.point, UIParent, position.relativePoint or position.point, position.x or 0, position.y or 0)
    else
        button:SetPoint("CENTER", UIParent, "CENTER", 0, -180)
    end

    self:Refresh()
end
