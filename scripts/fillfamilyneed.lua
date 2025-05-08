local dfhack = require("dfhack")
local units = dfhack.units

local function fulfill_family_need()
  local citizens = units.getCitizens()
  if not citizens then
    dfhack.printerr("No citizens found in the fortress.\n")
    return
  end

  local family_units = {} -- Store units with BeWithFamily need

  for _, unit in ipairs(citizens) do
    local mind = unit.status.current_soul
    if mind then
      for _, need in ipairs(mind.personality.needs) do
        if need.id == 7 then -- 7 is the numerical value for BeWithFamily
          family_units[unit.id] = {unit = unit, need = need} -- Store both unit and need
          break -- Only process BeWithFamily once per unit
        end
      end
    end
  end

  if next(family_units) == nil then
    dfhack.print("No units with BeWithFamily need found.\n")
    return
  end

  -- Directly fulfill the need
  for _, data in pairs(family_units) do
    local unit = data.unit
    local need = data.need
    need.focus_level = 400 -- Also set focus_level to 0 (important for some needs)
    unit.status.current_soul.personality.stress = -1000000
    dfhack.print("Family needs filled : ")
    dfhack.print(dfhack.units.getReadableName(unit))
    dfhack.print("\n")
  end
end

-- Run the script
fulfill_family_need()
