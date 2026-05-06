local m = {}

function m.Initialize(Entity, Data)
    local component = Entity:getComponent("illarion:visual")
    local visual = component:getVisual()
    local drawable = visual:getDrawable()
    drawable:getAnimationCompleted():connect(function()
        Entity:despawn()
    end)
end

return m