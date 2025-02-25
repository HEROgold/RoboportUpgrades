require("__heroic_library__.vars.words")
require("vars.settings")
require("vars.strings")
require("helpers.suffix")

local base_roboport_entity = data.raw[Roboport][Roboport]
local base_roboport_item = data.raw[Item][Roboport]

function generate_charging_offsets(n)
    local offsets = {}
    local min_offset = 1 -- 0.5
    local max_offset = 2 -- 1.5
    local step = 2 * math.pi / n

    for i = 0, n - 1 do
        local theta = step * i
        local r = (i % 2 == 0) and max_offset or min_offset
        local x = r * math.cos(theta)
        local y = r * math.sin(theta)
        table.insert(offsets, {x, y})
    end

    return offsets
end


local efficiency_limit = math.max(Limits[Efficiency], research_minimum)
local productivity_limit = math.max(Limits[Productivity], research_minimum)
local speed_limit = math.max(Limits[Speed], research_minimum)

local energy_roboport_entity = table.deepcopy(base_roboport_entity)
local energy_roboport_item = table.deepcopy(base_roboport_item)


energy_roboport_item.name = RoboportEnergy
energy_roboport_entity.name = RoboportEnergy

energy_roboport_item.place_result = energy_roboport_entity.name

energy_roboport_entity.minable.result = energy_roboport_item.name
energy_roboport_entity.robot_slots_count = 0
energy_roboport_entity.material_slots_count = 0

---@type data.RecipePrototype
local energy_roboport_recipe = {
    type = "recipe",
    name = RoboportEnergy,
    enabled = false,
    ---@type data.IngredientPrototype[]
    ingredients = {
        {type = Item, name =Roboport, amount = 1},
        {type = Item, name ="steel-plate", amount = 100},
    },
    ---@type data.ItemProductPrototype[]
    results = {{type = Item, name = energy_roboport_item.name, amount = 1},},
    category = "crafting",
    unlock_results = true,
}
local function add_energy_roboport()
    data:extend({energy_roboport_item})
    data:extend({energy_roboport_recipe})
    data:extend({energy_roboport_entity})
end

local function add_all_roboports()
    for e=0, efficiency_limit do
        for p=0, productivity_limit do
            for s=0, speed_limit do
                local roboport_item = table.deepcopy(energy_roboport_item)
                local roboport_entity = table.deepcopy(energy_roboport_entity)

                local suffix = get_energy_suffix(e, p, s)
                local name = combine{RoboportEnergyLeveled, suffix}

                roboport_entity.localised_name = {"entity-name." .. RoboportEnergyLeveled, tostring(e), tostring(p), tostring(s)}
                roboport_item.localised_name = {"item-name." .. RoboportEnergyLeveled, tostring(e), tostring(p), tostring(s)}

                roboport_item.name = name
                roboport_entity.name = name
                roboport_item.hidden = true

                roboport_item.place_result = roboport_entity.name

                roboport_entity.fast_replaceable_group = Roboport
                roboport_entity.minable = energy_roboport_entity.minable
                roboport_entity.minable.result = energy_roboport_item.name

                -- shorter var names, all changes follow the same logic. linear upgrade
                -- base + base * research_count * modifier.
                -- This makes sure we always get 200%, 300%, 400% etc from base 100%

                -- string.sub(x, 1, -3) to remove mw, kw, etc.
                local bifl = tonumber(string.sub(energy_roboport_entity.energy_source["input_flow_limit"], 1, -3))
                local bfc = tonumber(string.sub(energy_roboport_entity.energy_source["buffer_capacity"], 1, -3))
                local brm = tonumber(string.sub(energy_roboport_entity.recharge_minimum, 1, -3))
                local bru = tonumber(string.sub(energy_roboport_entity.energy_usage, 1, -3))
                local bce = tonumber(string.sub(energy_roboport_entity.charging_energy, 1, -3))
                local bcsc = #energy_roboport_entity.charging_offsets

                -- efficiency upgrades
                roboport_entity.energy_source = {
                    type = "electric",
                    usage_priority = "secondary-input",
                    input_flow_limit = tostring(bifl + bifl*e*input_flow_limit_modifier) .. "MW", --5 is default
                    buffer_capacity = tostring(bfc + bfc*e*buffer_capacity_modifier) .. "MJ", --100 is default
                }
                roboport_entity.recharge_minimum = tostring(brm + brm *e*recharge_minimum_modifier) .. "MJ" --50 is default in mj
                roboport_entity.energy_usage = tostring(bru + bru*e*energy_usage_modifier) .. "kW" -- 50 is default in kw, idle draw
                -- speed upgrade
                roboport_entity.charging_energy = tostring(bce + bce*s*charging_energy_modifier) .. "kW" -- 1000 is default in kw, amount of energy given to bots
                -- productivity upgrade -- 4 is default, amount of bots that can charge at once
                roboport_entity.charging_offsets = generate_charging_offsets(bcsc + bcsc * p)

                if settings.startup[ShowItems].value == true then
                    roboport_item.subgroup = ItemSubGroupRoboport
                    data:extend({roboport_item})
                end
                data:extend({roboport_entity})
            end
        end
    end
end

add_energy_roboport()
add_all_roboports()