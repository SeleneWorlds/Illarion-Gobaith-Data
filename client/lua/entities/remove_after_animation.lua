local m = {}

function m.Initialize(Entity, Data)
    local visual = Entity:GetVisual("illarion:visual")
    visual.AnimationCompleted:Connect(function()
        Entity:Despawn()
    end)
end

return m