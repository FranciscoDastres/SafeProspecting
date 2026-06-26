local _, NS = ...

local ActionState = {}
ActionState.__index = ActionState
NS.ActionState = ActionState

function ActionState:New()
    return setmetatable({ pending = nil }, self)
end

function ActionState:Begin(target, startedAt)
    if self.pending or not target then
        return nil
    end

    self.pending = {
        target = target,
        startedAt = startedAt,
        spellSucceeded = false,
        inventoryChanged = false,
    }
    return self.pending
end

function ActionState:MarkSpellSucceeded()
    if not self.pending then
        return false
    end
    self.pending.spellSucceeded = true
    return self:IsComplete()
end

function ActionState:MarkInventoryChanged()
    if not self.pending then
        return false
    end
    self.pending.inventoryChanged = true
    return self:IsComplete()
end

function ActionState:IsComplete()
    return self.pending ~= nil
        and self.pending.spellSucceeded == true
        and self.pending.inventoryChanged == true
end

function ActionState:IsCurrent(candidate)
    return self.pending == candidate
end

function ActionState:Clear()
    local previous = self.pending
    self.pending = nil
    return previous
end
