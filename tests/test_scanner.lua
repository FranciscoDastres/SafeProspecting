local namespace = {
    MIN_ORE_STACK = 5,
}

local addon = {
    db = {
        profile = {
            enabled = true,
            protectedItemIDs = {},
        },
    },
}
namespace.Addon = addon

local items = {
    [1] = { itemID = 23425, hyperlink = "item:23425", stackCount = 20, isLocked = false },
    [2] = { itemID = 23424, hyperlink = "item:23424", stackCount = 4, isLocked = false },
    [3] = { itemID = 23426, hyperlink = "item:23426", stackCount = 20, isLocked = false },
    [4] = { itemID = 72092, hyperlink = "item:72092", stackCount = 20, isLocked = false },
}

NUM_BAG_SLOTS = 0
C_Timer = { After = function(_, callback) callback() end }
C_Container = {
    GetContainerNumSlots = function() return 4 end,
    GetContainerItemInfo = function(_, slot) return items[slot] end,
    GetContainerNumFreeSlots = function() return 1, 0 end,
}
C_Item = {
    GetItemInfo = function(link)
        if link == "item:23425" then
            return "Adamantite Ore", link, 1, 65, 60, "Trade Goods", "Metal & Stone", 20, "", 1, 1, 7, 7, 0, 1
        elseif link == "item:23424" then
            return "Fel Iron Ore", link, 1, 60, 60, "Trade Goods", "Metal & Stone", 20, "", 2, 1, 7, 7, 0, 1
        elseif link == "item:23426" then
            return "Khorium Ore", link, 2, 70, 60, "Trade Goods", "Metal & Stone", 20, "", 3, 1, 7, 7, 0, 1
        elseif link == "item:72092" then
            return "Ghost Iron Ore", link, 1, 90, 85, "Trade Goods", "Metal & Stone", 20, "", 4, 1, 7, 7, 0, 1
        end
    end,
    RequestLoadItemDataByID = function() end,
}

assert(loadfile("Data.lua"))("SafeProspecting", namespace)
assert(loadfile("Rules.lua"))("SafeProspecting", namespace)

addon.OnTargetsChanged = function(_, targets)
    addon.lastTargets = targets
end

assert(loadfile("Scanner.lua"))("SafeProspecting", namespace)

namespace.Scanner:ScanNow()
assert(#namespace.TargetList == 2, "default scan should include two prospectable stacks")
assert(namespace.TargetList[1].itemID == 72092, "ghost iron should be first target")
assert(namespace.TargetList[2].itemID == 23425, "adamantite should be second target")
assert(namespace.TargetIndex["0:1"] ~= nil, "target index should contain the bag slot")
assert(namespace.TargetIndex["0:4"] ~= nil, "target index should contain the Mists bag slot")
assert(namespace.Scanner:HasFreeBagSlot(), "free bag slot should be detected")

local ghostIronTarget = namespace.TargetList[1]

items[4].stackCount = 15
assert(namespace.Scanner:DidTargetChange(ghostIronTarget), "lower stack count should confirm prospecting change")

items[4].stackCount = 20
assert(not namespace.Scanner:DidTargetChange(ghostIronTarget), "same stack count should not confirm completion")

items[4].isLocked = true
assert(namespace.Scanner:IsTargetLocked(ghostIronTarget), "current lock state should be read from the bag")

items[4] = nil
assert(not namespace.Scanner:IsTargetPresent(ghostIronTarget), "removed target should become stale")
assert(namespace.Scanner:DidTargetChange(ghostIronTarget), "removed target should count as inventory change")

print("SafeProspecting scanner tests passed")
