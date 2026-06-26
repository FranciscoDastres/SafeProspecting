# SafeProspecting

SafeProspecting is a manual-assisted prospecting addon for **WoW: The Burning
Crusade Classic Anniversary 2.5.5** (`Interface 20505`) and **WoW: Mists of
Pandaria Classic** (`Interface 50504`). It scans the player's bags, marks
prospectable ore stacks, adds approximate gem chances to ore tooltips, and
exposes one secure action for the stack currently shown.

## Safety model

- One physical click attempts to prospect exactly one displayed ore stack.
- The protected action is a `SecureActionButtonTemplate` with spell `31252` and
  fixed `target-bag` and `target-slot` attributes.
- Inventory scans, timers, and events never cast a spell or use an item.
- The queue advances only after the spell and an inventory quantity change are
  confirmed.
- Loot is never collected automatically.
- The button is disabled in combat, while loot is open, when bags are full, or
  when the target is stale or locked.

## Supported ores

The addon marks stacks of 5 or more of these ores:

- Copper Ore
- Tin Ore
- Iron Ore
- Mithril Ore
- Thorium Ore
- Fel Iron Ore
- Adamantite Ore
- Ghost Iron Ore
- Kyparite
- Black Trillium Ore
- White Trillium Ore

Silver, Gold, Truesilver, Dark Iron, Khorium, Eternium, quest ores, and other
non-whitelisted ores are not marked.

## Installation

Copy the complete `SafeProspecting` directory to:

```text
World of Warcraft/_anniversary_/Interface/AddOns/SafeProspecting
```

For Mists of Pandaria Classic, use the active MoP Classic AddOns directory, for
example:

```text
World of Warcraft/_mists_/Interface/AddOns/SafeProspecting
```

The final directory must contain `SafeProspecting.toc` and the bundled `Libs`
directory. Restart WoW or run `/reload` after installing.

## Commands

- `/safeprospecting config` or `/sp config` opens the Ace3 configuration.
- `/safeprospecting rescan` rebuilds the informational queue.
- `/safeprospecting show`, `/safeprospecting hide`, and `/safeprospecting toggle`
  control the action panel.

Drag the small handle above the action button to reposition it. Use the close
button on the action panel to hide it when idle, then left-click the minimap
button to show it again. Right-click the minimap button to open options.

## Development checks

The pure rules tests can run outside WoW with a Lua interpreter:

```bash
lua tests/test_rules.lua
lua tests/test_scanner.lua
```

All protected behavior still requires an in-game test on TBC Anniversary and
Mists of Pandaria Classic.

## Data provenance

The ore list, skill requirements, result item IDs, and approximate probabilities
were reviewed on 2026-06-26 against public Classic/TBC/Mists prospecting
references. No third-party addon code or assets are included. Item names are
never hardcoded; WoW resolves them from item IDs in the active locale.
