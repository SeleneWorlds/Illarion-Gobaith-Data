local Registries = require("selene.registries")

local Items = {}

local function worldName(itemName)
    local path = itemName:match("^illarion:(.+)$")
    return path and "illarion:items/" .. path
end

function Items.derive(item, options)
    options = options or {}
    local visual = assert(item:getField("visual"), "Item is missing its visual")
    local itemId = assert(item:getMetadata("id"), "Item is missing metadata.id")
    local tile = {
        visual = visual,
        mapColor = "#ffffff",
        impassable = item:getField("impassable") or false,
        passableAbove = item:getField("passableAbove") or false,
        metadata = { itemId = itemId },
        tags = { "illarion:item" }
    }
    local brightness = item:getField("brightness") or 0
    if options.tileLightFromBrightness ~= false and brightness > 0 then
        tile.light = { radius = brightness }
    end

    local components = {
        ["illarion:visual"] = { type = "visual", visual = visual }
    }
    if tile.passableAbove then
        components["selene:passable_above"] = { type = "passable_above" }
    end
    local entity = {
        components = components,
        metadata = { itemId = itemId },
        tags = options.entityTags or { "illarion:item", "illarion:supports_look_at" }
    }
    return tile, entity
end

local function createRuntime()
    local defaults = {}
    local generated = { ["selene:tiles"] = {}, ["selene:entities"] = {} }
    local writing = false

    local function mutate(callback)
        writing = true
        local ok, err = pcall(callback)
        writing = false
        if not ok then error(err) end
    end

    local function put(registry, name, definition)
        if generated[registry][name] or Registries.findByName(registry, name) == nil then
            mutate(function() Registries.add(registry, name, definition) end)
            generated[registry][name] = true
        end
    end

    local function update(item)
        local name = worldName(item:getName())
        if not name then return end
        local tile, entity = Items.derive(item, defaults)
        put("selene:tiles", name, tile)
        put("selene:entities", name, entity)
    end

    local function removeWorld(name)
        for registry, owned in pairs(generated) do
            if owned[name] then
                owned[name] = nil
                mutate(function() Registries.remove(registry, name) end)
            end
        end
    end

    local function refresh()
        local current = {}
        for _, item in pairs(Registries.findAll("illarion:items")) do
            local name = worldName(item:getName())
            if name then
                current[name] = true
                update(item)
            end
        end
        local stale = {}
        for _, owned in pairs(generated) do
            for name in pairs(owned) do
                if not current[name] then stale[name] = true end
            end
        end
        for name in pairs(stale) do removeWorld(name) end
    end

    local function start(options)
        defaults = options or {}
        -- The web client currently exposes startup mutations only; native runtimes also expose signals.
        if Registries.entryAdded then
            Registries.entryAdded("illarion:items"):connect(function(_, item) update(item) end)
            Registries.entryChanged("illarion:items"):connect(function(_, _, item) update(item) end)
            Registries.entryRemoved("illarion:items"):connect(function(name)
                local world = worldName(name)
                if world then removeWorld(world) end
            end)
            Registries.reloaded("illarion:items"):connect(refresh)
            for registry in pairs(generated) do
                local target = registry
                local function overridden(name)
                    if not writing then generated[target][name] = nil end
                end
                Registries.entryAdded(target):connect(overridden)
                Registries.entryChanged(target):connect(overridden)
                Registries.entryRemoved(target):connect(function(name)
                    if not writing then
                        generated[target][name] = nil
                        refresh()
                    end
                end)
                Registries.reloaded(target):connect(function()
                    generated[target] = {}
                    refresh()
                end)
            end
        end
        refresh()
    end

    return start
end

function Items.start(options)
    -- Entrypoints run again after bundle reloads, which also clear their event subscriptions.
    -- Keep ownership and subscriptions scoped to this entrypoint execution.
    return createRuntime()(options)
end

return Items
