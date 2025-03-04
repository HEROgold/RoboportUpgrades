require("__heroic_library__.vars.words")
require("vars.settings")
require("vars.strings")
require("helpers.suffix")

local base_roboport_entity = data.raw[Roboport][Roboport]
local base_roboport_item = data.raw[Item][Roboport]

local robot_storage_limit = math.max(robot_storage_limit, research_minimum)
local material_storage_limit = math.max(material_storage_limit, research_minimum)
local construction_area_limit = math.max(construction_area_limit, research_minimum)
local logistic_area_limit = math.max(logistic_area_limit, research_minimum)
local logistical_roboport_entity = table.deepcopy(base_roboport_entity)
local logistical_roboport_item = table.deepcopy(base_roboport_item)


logistical_roboport_item.name = RoboportLogistical
logistical_roboport_entity.name = RoboportLogistical

logistical_roboport_item.place_result = logistical_roboport_entity.name
-- logisitcal_roboport_item.hidden = false

logistical_roboport_entity.minable.result = logistical_roboport_item.name
logistical_roboport_entity.robot_slots_count = 10
logistical_roboport_entity.material_slots_count = 10

---@type data.RecipePrototype
local storage_roboport_recipe = {
    type = "recipe",
    name = RoboportLogistical,
    enabled = false,
    ---@type data.IngredientPrototype[]
    ingredients = {
        {type = Item, name =Roboport, amount = 1},
        {type = Item, name ="steel-plate", amount = 100},
    },
    ---@type data.ItemProductPrototype[]
    results = {{type = Item, name = logistical_roboport_entity.name, amount = 1},},
    category = "crafting",
    unlock_results = true,
}
local function add_storage_roboport()
    data:extend({logistical_roboport_item})
    data:extend({storage_roboport_recipe})
    data:extend({logistical_roboport_entity})
end

local function add_stacking_storage_roboport()
    for c=0, construction_area_limit do 
        for l=0, logistic_area_limit do
            for r=0, robot_storage_limit do
                for m=0, material_storage_limit do
                    local roboport_item = table.deepcopy(logistical_roboport_item)
                    local roboport_entity = table.deepcopy(logistical_roboport_entity)

                    local suffix = get_storage_suffix(c, l, r, m)
                    local name = combine{RoboportLogisticalLeveled, suffix}

                    roboport_entity.localised_name = {"entity-name." .. RoboportLogisticalLeveled, tostring(c), tostring(l), tostring(r), tostring(m)}
                    roboport_item.localised_name = {"item-name." .. RoboportLogisticalLeveled, tostring(c), tostring(l), tostring(r), tostring(m)}

                    roboport_item.name = name
                    roboport_entity.name = name
                    roboport_item.place_result = roboport_entity.name
                    roboport_item.hidden = true

                    -- Level * base, + base
                    rb = logistical_roboport_entity.robot_slots_count
                    mb = logistical_roboport_entity.material_slots_count
                    cb = logistical_roboport_entity.construction_radius
                    lb = logistical_roboport_entity.logistics_radius
                    ldb = logistical_roboport_entity.logistics_connection_distance or lb

                    roboport_entity.robot_slots_count = (rb * r) + rb
                    roboport_entity.material_slots_count = (mb * m) + mb
                    roboport_entity.construction_radius = (cb * c) + cb
                    roboport_entity.logistics_radius = (lb * l) + lb
                    roboport_entity.logistics_connection_distance = (ldb * l) + ldb
                    -- roboport_entity.minable = logisitcal_roboport_entity.minable
                    -- roboport_entity.minable.result = logisitcal_roboport_entity.name

                    if settings.startup[ShowItems].value == true then
                        roboport_item.subgroup = ItemSubGroupRoboport
                        data:extend({roboport_item})
                    end

                    data:extend({roboport_entity})
                end
            end
        end
    end
end

add_storage_roboport()
add_stacking_storage_roboport()
