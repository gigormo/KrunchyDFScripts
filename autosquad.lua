local gui = require('gui')
local overlay = require('plugins.overlay')
local setbelief = reqscript('modtools/set-belief')
local utils = require('utils')
local widgets = require('gui.widgets')
local argparse = require('argparse')

local function get_rating(val, baseline, range, highest, high, med, low)
    val = val - (baseline or 0)
    range = range or 100
    local percentile = (math.min(range, val) * 100) // range
    if percentile < (low or 25) then return percentile end
    if percentile < (med or 50) then return percentile end
    if percentile < (high or 75) then return percentile end
    if percentile < (highest or 90) then return percentile end
    return percentile
end

local function get_mental_stability(unit)
    local altruism = unit.status.current_soul.personality.traits.ALTRUISM
    local anxiety_propensity = unit.status.current_soul.personality.traits.ANXIETY_PROPENSITY
    local bravery = unit.status.current_soul.personality.traits.BRAVERY
    local cheer_propensity = unit.status.current_soul.personality.traits.CHEER_PROPENSITY
    local curious = unit.status.current_soul.personality.traits.CURIOUS
    local discord = unit.status.current_soul.personality.traits.DISCORD
    local dutifulness = unit.status.current_soul.personality.traits.DUTIFULNESS
    local emotionally_obsessive = unit.status.current_soul.personality.traits.EMOTIONALLY_OBSESSIVE
    local humor = unit.status.current_soul.personality.traits.HUMOR
    local love_propensity = unit.status.current_soul.personality.traits.LOVE_PROPENSITY
    local perseverence = unit.status.current_soul.personality.traits.PERSEVERENCE
    local politeness = unit.status.current_soul.personality.traits.POLITENESS
    local privacy = unit.status.current_soul.personality.traits.PRIVACY
    local stress_vulnerability = unit.status.current_soul.personality.traits.STRESS_VULNERABILITY
    local tolerant = unit.status.current_soul.personality.traits.TOLERANT

    local craftsmanship = setbelief.getUnitBelief(unit, df.value_type['CRAFTSMANSHIP'])
    local family = setbelief.getUnitBelief(unit, df.value_type['FAMILY'])
    local harmony = setbelief.getUnitBelief(unit, df.value_type['HARMONY'])
    local independence = setbelief.getUnitBelief(unit, df.value_type['INDEPENDENCE'])
    local knowledge = setbelief.getUnitBelief(unit, df.value_type['KNOWLEDGE'])
    local leisure_time = setbelief.getUnitBelief(unit, df.value_type['LEISURE_TIME'])
    local nature = setbelief.getUnitBelief(unit, df.value_type['NATURE'])
    local skill = setbelief.getUnitBelief(unit, df.value_type['SKILL'])

    -- calculate the rating using the defined variables
    local rating = (craftsmanship * -0.01) + (family * -0.09) + (harmony * 0.05)
                    + (independence * 0.06) + (knowledge * -0.30) + (leisure_time * 0.24)
                    + (nature * 0.27) + (skill * -0.21) + (altruism * 0.13)
                    + (anxiety_propensity * -0.06) + (bravery * 0.06)
                    + (cheer_propensity * 0.41) + (curious * -0.06) + (discord * 0.14)
                    + (dutifulness * -0.03) + (emotionally_obsessive * -0.13)
                    + (humor * -0.05) + (love_propensity * 0.15) + (perseverence * -0.07)
                    + (politeness * -0.14) + (privacy * 0.03) + (stress_vulnerability * -0.20)
                    + (tolerant * -0.11)

    return rating
end

local function is_unstable(unit)
    local percentile = get_rating(get_mental_stability(unit), -40, 80, 35, 0, 0, 0)
    local instability_percentile_threshold = 35
    return percentile < instability_percentile_threshold
end

local function is_maimed(unit)
    return not unit.flags2.vision_good or
           unit.status2.limbs_grasp_count < 2 or
           unit.status2.limbs_stand_count == 0
end

local MELEE_WEAPON_SKILLS = {
    df.job_skill.AXE,
    df.job_skill.SWORD,
    df.job_skill.MACE,
    df.job_skill.HAMMER,
    df.job_skill.SPEAR,
}

local function melee_skill_effectiveness(unit)
    -- Physical attributes
    local strength = dfhack.units.getPhysicalAttrValue(unit, df.physical_attribute_type.STRENGTH)
    local agility = dfhack.units.getPhysicalAttrValue(unit, df.physical_attribute_type.AGILITY)
    local toughness = dfhack.units.getPhysicalAttrValue(unit, df.physical_attribute_type.TOUGHNESS)
    local endurance = dfhack.units.getPhysicalAttrValue(unit, df.physical_attribute_type.ENDURANCE)
    local body_size_base = unit.body.size_info.size_base

    -- Mental attributes
    local willpower = dfhack.units.getMentalAttrValue(unit, df.mental_attribute_type.WILLPOWER)
    local spatial_sense = dfhack.units.getMentalAttrValue(unit, df.mental_attribute_type.SPATIAL_SENSE)
    local kinesthetic_sense = dfhack.units.getMentalAttrValue(unit, df.mental_attribute_type.KINESTHETIC_SENSE)

    -- Skills
    local skill_rating = 0
    for _, skill in ipairs(MELEE_WEAPON_SKILLS) do
        local melee_skill = dfhack.units.getNominalSkill(unit, skill, true)
        skill_rating = math.max(skill_rating, melee_skill)
    end
    local melee_combat_rating = dfhack.units.getNominalSkill(unit, df.job_skill.MELEE_COMBAT, true)

    local rating = skill_rating * 27000 + melee_combat_rating * 9000
                    + strength * 180 + body_size_base * 100 + kinesthetic_sense * 50 + endurance * 50
                    + agility * 30 + toughness * 20 + willpower * 20 + spatial_sense * 20
    return rating
end

local function get_melee_skill_effectiveness_rating(unit)
    return get_rating(melee_skill_effectiveness(unit), 350000, 2750000, 64, 52, 40, 28)
end

local function get_melee_combat_potential(unit)
    -- Physical attributes
    local strength = unit.body.physical_attrs.STRENGTH.max_value
    local agility = unit.body.physical_attrs.AGILITY.max_value
    local toughness = unit.body.physical_attrs.TOUGHNESS.max_value
    local endurance = unit.body.physical_attrs.ENDURANCE.max_value
    local body_size_base = unit.body.size_info.size_base

    -- Mental attributes
    local willpower = unit.status.current_soul.mental_attrs.WILLPOWER.max_value
    local spatial_sense = unit.status.current_soul.mental_attrs.SPATIAL_SENSE.max_value
    local kinesthetic_sense = unit.status.current_soul.mental_attrs.KINESTHETIC_SENSE.max_value

    -- assume highest skill ratings
    local skill_rating = df.skill_rating.Legendary5
    local melee_combat_rating = df.skill_rating.Legendary5

    -- melee combat potential rating
    local rating = skill_rating * 27000 + melee_combat_rating * 9000
                    + strength * 180 + body_size_base * 100 + kinesthetic_sense * 50 + endurance * 50
                    + agility * 30 + toughness * 20 + willpower * 20 + spatial_sense * 20
    return rating
end

local function get_melee_combat_potential_rating(unit)
    return get_rating(get_melee_combat_potential(unit), 350000, 2750000, 64, 52, 40, 28)
end

function assignFreeSquadPosition(unit)
    -- First, check if the dwarf is suitable for military service
    if is_maimed(unit) or is_unstable(unit) then
        return -- Skip this dwarf if they are maimed or unstable
    end

    for i, squad in pairs( df.global.world.squads.all ) do
        if squad.symbol ~= -1 then
            for j, position in pairs( squad.positions ) do
                if position.occupant == -1 then
                    position.occupant = unit.hist_figure_id
                    unit.military.squad_id = squad.id
                    unit.military.squad_position = j
                    return
                end
            end
        end
    end
end

function fillSquads(sort_type)
    local eligible_dwarves = {}

    -- Collect all eligible squadless dwarves and their melee skill effectiveness
    for i, unit in pairs( df.global.world.units.active ) do
        if dfhack.units.isCitizen(unit) and unit.military.squad_id == -1 and unit.profession ~= 103 then
            if not is_maimed(unit) and not is_unstable(unit) then
                local effectiveness_percentile = get_melee_skill_effectiveness_rating(unit)
                local potential_percentile = get_melee_combat_potential_rating(unit)
                table.insert(eligible_dwarves, {
                    unit = unit,
                    effectiveness = effectiveness_percentile,
                    potential = potential_percentile
                })
            end
        end
    end

    -- Sort the eligible dwarves
    if sort_type == "potential" then
        table.sort(eligible_dwarves, function(a, b)
            return a.potential > b.potential
        end)
    elseif sort_type == "effectiveness" then
        table.sort(eligible_dwarves, function(a, b)
            return a.effectiveness > b.effectiveness
        end)
    else
        -- Default sort by effectiveness
        table.sort(eligible_dwarves, function(a, b)
            return a.effectiveness > b.effectiveness
        end)
    end

    -- Assign the sorted dwarves to any free squad positions
    for _, dwarf_info in ipairs(eligible_dwarves) do
        assignFreeSquadPosition(dwarf_info.unit)
    end
end

local argparse = require('argparse')
local parser = argparse.newParser{
    description = "Fills military squads, sorting by effectiveness or potential.",
    usage = "autosquad.lua [-s <sort_type>]"
}

parser:addArgument('sort_type', '-s', {
    choices = {'effectiveness', 'potential'},
    defaultValue = 'effectiveness',
    help = "Sort dwarves by 'effectiveness' or 'potential'.",
    })
local args = parser:parse()

fillSquads(args.sort_type)
