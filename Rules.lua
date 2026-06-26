local _, NS = ...

local Rules = {}
NS.Rules = Rules

function Rules.GetOreRule(itemID)
    return NS.Data.OresByItemID[tonumber(itemID or 0)]
end

function Rules.GetOutcomes(itemID)
    local ore = Rules.GetOreRule(itemID)
    return ore and ore.outcomes or nil
end

function Rules.EvaluateCandidate(item, profile)
    if not profile or not profile.enabled then
        return false, "disabled"
    end

    local ore = Rules.GetOreRule(item.itemID)
    if not ore then
        return false, "not-ore"
    end

    if (tonumber(item.stackCount) or 0) < NS.MIN_ORE_STACK then
        return false, "stack"
    end

    if profile.protectedItemIDs and profile.protectedItemIDs[item.itemID] then
        return false, "protected"
    end

    item.requiredSkill = ore.requiredSkill
    item.outcomes = ore.outcomes
    return true
end

function Rules.SortTargets(targets)
    table.sort(targets, function(left, right)
        if left.requiredSkill ~= right.requiredSkill then
            return left.requiredSkill > right.requiredSkill
        end
        if left.bag ~= right.bag then
            return left.bag < right.bag
        end
        return left.slot < right.slot
    end)
    return targets
end

function Rules.MakeTargetKey(bag, slot)
    return tostring(bag) .. ":" .. tostring(slot)
end
