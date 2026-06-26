local namespace = {
    MIN_ORE_STACK = 5,
}

assert(loadfile("Data.lua"))("SafeProspecting", namespace)
assert(loadfile("Rules.lua"))("SafeProspecting", namespace)
assert(loadfile("ActionState.lua"))("SafeProspecting", namespace)

local function equal(actual, expected, label)
    assert(actual == expected, string.format("%s: expected %s, got %s", label, tostring(expected), tostring(actual)))
end

local copperResults = namespace.Rules.GetOutcomes(2770)
equal(#copperResults, 3, "copper has three listed outcomes")
equal(copperResults[1].itemID, 818, "copper can yield Tigerseye")
equal(copperResults[1].chance, 50, "Tigerseye chance")

local adamantiteResults = namespace.Rules.GetOutcomes(23425)
equal(adamantiteResults[1].itemID, 24243, "adamantite can yield powder")
equal(adamantiteResults[1].chance, 65, "adamantite powder chance")
equal(namespace.Rules.GetOutcomes(23426), nil, "khorium is not prospectable")

local ghostIronResults = namespace.Rules.GetOutcomes(72092)
equal(#ghostIronResults, 13, "ghost iron has Mists outcomes")
equal(ghostIronResults[1].itemID, 76130, "ghost iron can yield Tiger Opal")
equal(ghostIronResults[13].itemID, 90407, "ghost iron can yield Sparkling Shards")
equal(ghostIronResults[13].maxQuantity, 2, "sparkling shards can stack to two")

local profile = {
    enabled = true,
    protectedItemIDs = {},
}
local candidate = {
    itemID = 23425,
    stackCount = 20,
    bag = 0,
    slot = 1,
}

equal(namespace.Rules.EvaluateCandidate(candidate, profile), true, "valid adamantite stack")
equal(candidate.requiredSkill, 325, "required skill attached")

candidate.itemID = 72092
equal(namespace.Rules.EvaluateCandidate(candidate, profile), true, "valid ghost iron stack")
equal(candidate.requiredSkill, 500, "Mists required skill attached")
candidate.itemID = 23425

candidate.stackCount = 4
local eligible, reason = namespace.Rules.EvaluateCandidate(candidate, profile)
equal(eligible, false, "short stack excluded")
equal(reason, "stack", "short stack reason")
candidate.stackCount = 5

profile.protectedItemIDs[candidate.itemID] = true
equal(namespace.Rules.EvaluateCandidate(candidate, profile), false, "protected ore excluded")
profile.protectedItemIDs[candidate.itemID] = nil

candidate.itemID = 23426
equal(namespace.Rules.EvaluateCandidate(candidate, profile), false, "non-whitelisted ore excluded")

local targets = {
    { requiredSkill = 20, bag = 0, slot = 3 },
    { requiredSkill = 325, bag = 4, slot = 1 },
    { requiredSkill = 325, bag = 0, slot = 2 },
}
namespace.Rules.SortTargets(targets)
equal(targets[1].bag, 0, "highest skill sorts first by bag")
equal(targets[2].bag, 4, "same skill second bag")
equal(targets[3].requiredSkill, 20, "low skill last")

local actionState = namespace.ActionState:New()
local pending = actionState:Begin({ itemID = 23425 }, 10)
equal(actionState:IsComplete(), false, "new action is incomplete")
equal(actionState:MarkSpellSucceeded(), false, "spell alone does not advance")
equal(actionState:MarkInventoryChanged(), true, "spell plus inventory change advances")
equal(actionState:IsCurrent(pending), true, "pending identity")
equal(actionState:Clear().target.itemID, 23425, "clear returns completed target")
equal(actionState.pending, nil, "clear resets state")

print("SafeProspecting rules tests passed")
