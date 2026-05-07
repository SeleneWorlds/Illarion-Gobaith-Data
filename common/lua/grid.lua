local Grid = require("selene.grid")

local m = {}

m.North = Grid.defineDirection("north", 0, -1, 0, 0)
m.South = Grid.defineDirection("south", 0, 1, 0, 180)
m.East = Grid.defineDirection("east", 1, 0, 0, 90)
m.West = Grid.defineDirection("west", -1, 0, 0, 270)

return m