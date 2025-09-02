local m = {}

function m.Initialize(Entity, Data)
    local component = Entity:GetComponent("illarion:visual")
    local visual = component.Visual
    local drawable = visual.Drawable
    drawable.AnimationCompleted:Connect(function()
        Entity:Despawn()
    end)
end

return m