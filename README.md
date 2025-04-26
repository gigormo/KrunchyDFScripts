# Lua Scripts for Dwarf Fortress

A collection of Lua scripts to enhance your game.

---

## `autosquad`
Automatically fills vacant military squads. Prioritizes dwarves based on melee skill effectiveness (best assigned first). Ignores maimed and mentally unstable dwarves.
**Functionality:**
* Identifies squadless civilian dwarves.
* Calculates a melee skill effectiveness rating.
* Excludes maimed or mentally unstable dwarves.
* Assigns remaining dwarves to open squad positions, highest effectiveness first.
**Usage:**
1.  Open the DFHack console.
2.  Run: `lua -f hack/scripts/autosquad.lua`
**Key Features:**
* Automated squad filling.
* Prioritizes higher melee skill.
* Skips maimed dwarves.
* Skips mentally unstable dwarves.