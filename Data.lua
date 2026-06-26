local _, NS = ...

-- Probabilities are approximate per-prospect chances from public Classic/TBC
-- prospecting tables. They describe the chance for each listed result to
-- appear, not a mutually exclusive distribution that sums to 100%.

local I = {
    COPPER_ORE = 2770,
    TIN_ORE = 2771,
    IRON_ORE = 2772,
    MITHRIL_ORE = 3858,
    THORIUM_ORE = 10620,
    FEL_IRON_ORE = 23424,
    ADAMANTITE_ORE = 23425,

    TIGERSEYE = 818,
    MALACHITE = 774,
    SHADOWGEM = 1210,
    LESSER_MOONSTONE = 1705,
    MOSS_AGATE = 1206,
    JADE = 1529,
    CITRINE = 3864,
    AQUAMARINE = 7909,
    STAR_RUBY = 7910,
    BLUE_SAPPHIRE = 12361,
    LARGE_OPAL = 12799,
    AZEROTHIAN_DIAMOND = 12800,
    HUGE_EMERALD = 12364,
    BLOOD_GARNET = 23077,
    FLAME_SPESSARITE = 21929,
    GOLDEN_DRAENITE = 23112,
    DEEP_PERIDOT = 23079,
    AZURE_MOONSTONE = 23117,
    SHADOW_DRAENITE = 23107,
    LIVING_RUBY = 23436,
    NOBLE_TOPAZ = 23439,
    DAWNSTONE = 23440,
    TALASITE = 23437,
    STAR_OF_ELUNE = 23438,
    NIGHTSEYE = 23441,
    ADAMANTITE_POWDER = 24243,
}

local function outcome(itemID, chance)
    return {
        itemID = itemID,
        chance = chance,
        minQuantity = 1,
        maxQuantity = 1,
    }
end

local function ore(itemID, requiredSkill, outcomes)
    return {
        itemID = itemID,
        requiredSkill = requiredSkill,
        outcomes = outcomes,
    }
end

local ores = {
    ore(I.COPPER_ORE, 20, {
        outcome(I.TIGERSEYE, 50),
        outcome(I.MALACHITE, 50),
        outcome(I.SHADOWGEM, 10),
    }),
    ore(I.TIN_ORE, 50, {
        outcome(I.SHADOWGEM, 37.5),
        outcome(I.LESSER_MOONSTONE, 37.5),
        outcome(I.MOSS_AGATE, 37.5),
        outcome(I.CITRINE, 3.33),
        outcome(I.JADE, 3.33),
        outcome(I.AQUAMARINE, 3.33),
    }),
    ore(I.IRON_ORE, 125, {
        outcome(I.CITRINE, 30),
        outcome(I.LESSER_MOONSTONE, 30),
        outcome(I.JADE, 30),
        outcome(I.AQUAMARINE, 5),
        outcome(I.STAR_RUBY, 5),
    }),
    ore(I.MITHRIL_ORE, 175, {
        outcome(I.CITRINE, 30),
        outcome(I.STAR_RUBY, 30),
        outcome(I.AQUAMARINE, 30),
        outcome(I.AZEROTHIAN_DIAMOND, 2.5),
        outcome(I.BLUE_SAPPHIRE, 2.5),
        outcome(I.LARGE_OPAL, 2.5),
        outcome(I.HUGE_EMERALD, 2.5),
    }),
    ore(I.THORIUM_ORE, 250, {
        outcome(I.STAR_RUBY, 30),
        outcome(I.LARGE_OPAL, 16),
        outcome(I.BLUE_SAPPHIRE, 16),
        outcome(I.HUGE_EMERALD, 16),
        outcome(I.AZEROTHIAN_DIAMOND, 16),
        outcome(I.BLOOD_GARNET, 1.66),
        outcome(I.FLAME_SPESSARITE, 1.66),
        outcome(I.GOLDEN_DRAENITE, 1.66),
        outcome(I.DEEP_PERIDOT, 1.66),
        outcome(I.AZURE_MOONSTONE, 1.66),
        outcome(I.SHADOW_DRAENITE, 1.66),
    }),
    ore(I.FEL_IRON_ORE, 275, {
        outcome(I.BLOOD_GARNET, 17),
        outcome(I.FLAME_SPESSARITE, 17),
        outcome(I.GOLDEN_DRAENITE, 17),
        outcome(I.DEEP_PERIDOT, 17),
        outcome(I.AZURE_MOONSTONE, 17),
        outcome(I.SHADOW_DRAENITE, 17),
        outcome(I.LIVING_RUBY, 1),
        outcome(I.NOBLE_TOPAZ, 1),
        outcome(I.DAWNSTONE, 1),
        outcome(I.TALASITE, 1),
        outcome(I.STAR_OF_ELUNE, 1),
        outcome(I.NIGHTSEYE, 1),
    }),
    ore(I.ADAMANTITE_ORE, 325, {
        outcome(I.ADAMANTITE_POWDER, 65),
        outcome(I.BLOOD_GARNET, 19),
        outcome(I.FLAME_SPESSARITE, 19),
        outcome(I.GOLDEN_DRAENITE, 19),
        outcome(I.DEEP_PERIDOT, 19),
        outcome(I.AZURE_MOONSTONE, 19),
        outcome(I.SHADOW_DRAENITE, 19),
        outcome(I.LIVING_RUBY, 3),
        outcome(I.NOBLE_TOPAZ, 3),
        outcome(I.DAWNSTONE, 3),
        outcome(I.TALASITE, 3),
        outcome(I.STAR_OF_ELUNE, 3),
        outcome(I.NIGHTSEYE, 3),
    }),
}

local oresByItemID = {}
local materials = {}
for index = 1, #ores do
    local entry = ores[index]
    oresByItemID[entry.itemID] = entry
    materials[#materials + 1] = entry.itemID
    for outcomeIndex = 1, #entry.outcomes do
        materials[#materials + 1] = entry.outcomes[outcomeIndex].itemID
    end
end

NS.Data = {
    Items = I,
    Ores = ores,
    OresByItemID = oresByItemID,
    Materials = materials,
    Source = {
        name = "Classic/TBC prospecting tables",
        reviewed = "2026-06-25",
        probabilitiesAreApproximate = true,
    },
}
