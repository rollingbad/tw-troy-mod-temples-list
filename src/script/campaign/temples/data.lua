local debug = require("tw-debug")("mk:temples:data")

local data = {}

-- list of temples building chain keys
local TEMPLE_CHAINS = {
    Aphrodite = "troy_main_religion_aphrodite",
    Apollo = "troy_main_religion_apollo",
    Ares = "troy_main_religion_ares",
    Athena = "troy_main_religion_athens",
    Hera = "troy_main_religion_hera",
    Poseidon = "troy_main_religion_poseidon",
    Zeus = "troy_main_religion_zeus"
}

local function getOwnedCapitals()
    local faction = cm:get_faction(cm:get_local_faction())
    local regions = faction:region_list()
    local capitals = {}

    for i = 0, regions:num_items() - 1 do
        local region = regions:item_at(i)

        if region:is_province_capital() then
            table.insert(capitals, region)
        end
    end

    return capitals
end

local function getTempleBuildingChain(region)
    local temple = ""
    local god = ""
    for key, buildingChainKey in pairs(TEMPLE_CHAINS) do
        local garrison = region:garrison_residence()
        if cm:garrison_contains_building_chain(garrison, buildingChainKey) then
            temple = buildingChainKey
            god = key
            break
        end
    end

    return temple, god
end

local function getTempleBuildingKeyAndLevel(region, buildingChainKey)
    local garrison = region:garrison_residence()
    local suffixes = {"_2", "_3", "_4"}
    local result = ""
    local level = ""

    for key, suffix in pairs(suffixes) do
        local buildingKey = buildingChainKey .. suffix
        if cm:garrison_contains_building(garrison, buildingKey) then
            result = buildingKey
            level = string.gsub(suffix, "_", "")
            break
        end
    end

    return result, level
end

local function getTemplesData(regions)
    regions = regions or getOwnedCapitals()
    debug("getTemplesData for", #regions, "regions");

    local result = {}
    for i = 1, #regions do
        local region = regions[i]
        local templeBuildingChain, god = getTempleBuildingChain(region)
        local regionName = region:name()
        local provinceName = region:province_name()
        local temple = ""
        local level = ""
        local icon = ""
        local key = "none"

        if templeBuildingChain ~= "" then
            key = god
            temple, level = getTempleBuildingKeyAndLevel(region, templeBuildingChain)
            icon = "ui/buildings/icons/build_icon_" .. string.lower(god) .. "_religious.png"
        end

        result[key] = result[key] or {}
        table.insert(result[key], {
            region = regionName,
            province = provinceName,
            temple = temple,
            icon = icon,
            level = level
        })
    end

    -- sort each god temples table per building level
    for k, v in pairs(result) do
        debug("Sort result data", k)
        local temples = result[k]
        debug("temples", temples)

        if k ~= "none" then
            table.sort(temples, function(a, b)
                local levelA = tonumber(a.level)
                local levelB = tonumber(b.level)
                
                return levelA < levelB
            end)
        end
    end

    return result
end

data.TEMPLE_CHAINS = TEMPLE_CHAINS
data.getOwnedCapitals = getOwnedCapitals
data.getTempleBuildingChain = getTempleBuildingChain
data.getTempleBuildingKey = getTempleBuildingKey
data.getTemplesData = getTemplesData

return data