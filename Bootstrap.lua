local addonName, NS = ...

NS.ADDON_NAME = addonName
NS.VERSION = "0.1.0"
NS.PROSPECTING_SPELL_ID = 31252
NS.MIN_ORE_STACK = 5

NS.Addon = LibStub("AceAddon-3.0"):NewAddon(
    "SafeProspecting",
    "AceConsole-3.0"
)

NS.TargetList = {}
NS.TargetIndex = {}
