local _, NS = ...

-- Probabilities are approximate per-prospect chances from public Classic/TBC
-- and Mists Classic prospecting tables. They describe the chance for each
-- listed result to appear, not a mutually exclusive distribution that sums to
-- 100%.

local I = {
    COPPER_ORE = 2770,
    TIN_ORE = 2771,
    IRON_ORE = 2772,
    MITHRIL_ORE = 3858,
    THORIUM_ORE = 10620,
    FEL_IRON_ORE = 23424,
    ADAMANTITE_ORE = 23425,
    GHOST_IRON_ORE = 72092,
    KYPARITE = 72093,
    BLACK_TRILLIUM_ORE = 72094,
    WHITE_TRILLIUM_ORE = 72103,

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
    TIGER_OPAL = 76130,
    PRIMORDIAL_RUBY = 76131,
    LAPIS_LAZULI = 76133,
    SUNSTONE = 76134,
    ROGUESTONE = 76135,
    PANDARIAN_GARNET = 76136,
    ALEXANDRITE = 76137,
    RIVERS_HEART = 76138,
    WILD_JADE = 76139,
    VERMILION_ONYX = 76140,
    IMPERIAL_AMETHYST = 76141,
    SUNS_RADIANCE = 76142,
    SPARKLING_SHARD = 90407,
}

local function outcome(itemID, chance, minQuantity, maxQuantity)
    return {
        itemID = itemID,
        chance = chance,
        minQuantity = minQuantity or 1,
        maxQuantity = maxQuantity or minQuantity or 1,
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
    ore(I.GHOST_IRON_ORE, 500, {
        outcome(I.TIGER_OPAL, 19.45),
        outcome(I.PRIMORDIAL_RUBY, 3.93),
        outcome(I.LAPIS_LAZULI, 19.26),
        outcome(I.SUNSTONE, 18.69),
        outcome(I.ROGUESTONE, 18.94),
        outcome(I.PANDARIAN_GARNET, 19.04),
        outcome(I.ALEXANDRITE, 19.03),
        outcome(I.RIVERS_HEART, 4.19),
        outcome(I.WILD_JADE, 3.43),
        outcome(I.VERMILION_ONYX, 3.86),
        outcome(I.IMPERIAL_AMETHYST, 3.31),
        outcome(I.SUNS_RADIANCE, 3.57),
        outcome(I.SPARKLING_SHARD, 82.08, 1, 2),
    }),
    ore(I.KYPARITE, 550, {
        outcome(I.TIGER_OPAL, 18.29),
        outcome(I.PRIMORDIAL_RUBY, 3.25),
        outcome(I.LAPIS_LAZULI, 17.92),
        outcome(I.SUNSTONE, 18.34),
        outcome(I.ROGUESTONE, 19.78),
        outcome(I.PANDARIAN_GARNET, 21.02),
        outcome(I.ALEXANDRITE, 18.84),
        outcome(I.RIVERS_HEART, 3.29),
        outcome(I.WILD_JADE, 3.90),
        outcome(I.VERMILION_ONYX, 4.13),
        outcome(I.IMPERIAL_AMETHYST, 4.63),
        outcome(I.SUNS_RADIANCE, 4.79),
        outcome(I.SPARKLING_SHARD, 98.40, 1, 2),
    }),
    ore(I.BLACK_TRILLIUM_ORE, 600, {
        outcome(I.TIGER_OPAL, 10.87),
        outcome(I.PRIMORDIAL_RUBY, 12.73),
        outcome(I.LAPIS_LAZULI, 12.96),
        outcome(I.SUNSTONE, 14.72),
        outcome(I.ROGUESTONE, 16.17),
        outcome(I.PANDARIAN_GARNET, 12.01),
        outcome(I.ALEXANDRITE, 14.15),
        outcome(I.RIVERS_HEART, 15.29),
        outcome(I.WILD_JADE, 13.02),
        outcome(I.VERMILION_ONYX, 19.03),
        outcome(I.IMPERIAL_AMETHYST, 12.73),
        outcome(I.SUNS_RADIANCE, 15.70),
        outcome(I.SPARKLING_SHARD, 95.45, 1, 2),
    }),
    ore(I.WHITE_TRILLIUM_ORE, 600, {
        outcome(I.TIGER_OPAL, 15.20),
        outcome(I.PRIMORDIAL_RUBY, 14.46),
        outcome(I.LAPIS_LAZULI, 13.82),
        outcome(I.SUNSTONE, 15.85),
        outcome(I.ROGUESTONE, 14.78),
        outcome(I.PANDARIAN_GARNET, 14.88),
        outcome(I.ALEXANDRITE, 9.96),
        outcome(I.RIVERS_HEART, 14.54),
        outcome(I.WILD_JADE, 11.42),
        outcome(I.VERMILION_ONYX, 11.35),
        outcome(I.IMPERIAL_AMETHYST, 12.56),
        outcome(I.SUNS_RADIANCE, 11.37),
        outcome(I.SPARKLING_SHARD, 96.71, 1, 2),
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
        name = "Classic/TBC/Mists prospecting tables",
        reviewed = "2026-06-26",
        probabilitiesAreApproximate = true,
    },
}
