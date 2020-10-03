local debug = require("tw-debug")("mk:temples:mod")

-- workaround to get core object accessible in required ui file
_G.core = core;
_G.find_uicomponent = find_uicomponent

local ui = require("temples/ui")

-- list of factions for which this mod is not enabled
local IGNORED_FACTIONS = { "troy_amazons_trj_penthesilea" }

local function init()
    debug("Init")

    local faction = cm:get_local_faction()
    local enabled = true

    debug(IGNORED_FACTIONS, faction)
    for k, v in pairs(IGNORED_FACTIONS) do
        debug("Check %s against %s", faction, v)
        if faction == v then
            debug("Disable mod")
            enabled = false
            break
        end
    end

    if enabled then
        ui.init()
    end

    debug("Done")
end


cm:add_first_tick_callback(init)