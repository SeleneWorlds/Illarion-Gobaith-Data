local Grid = require("selene.grid")

local m = {}

m.North = Grid.DefineDirection("north", 0, -1, 0, 0)
m.South = Grid.DefineDirection("south", 0, 1, 0, 180)
m.East = Grid.DefineDirection("east", 1, 0, 0, 90)
m.West = Grid.DefineDirection("west", -1, 0, 0, 270)

return m