-- where the coterie is, where they're looking and how they walk
local direction = require("src.direction")

local Party = {}
Party.__index = Party

function Party.new(x, y, dir)
    local self = setmetatable({}, Party)
    self.x = x or 2
    self.y = y or 2
    self.dir = dir or 1
    self.members = {}
    return self
end

function Party:turnRight()
    self.dir = direction.right(self.dir)
end

function Party:turnLeft()
    self.dir = direction.left(self.dir)
end

-- the four uses of step: (1, 0) walks ahead; (-1, 0) backwards, (0, -1) sideways to the left; (0, 1) sideways to the right
-- the coterie doesn't turn as they walk sideways: something from the classics like Eye of the Beholder and Realms of Arkania
function Party:step(map, ahead, side)
    local nx, ny = direction.toGrid(self.x, self.y, self.dir, ahead, side)
    if not map:isFree(nx, ny) then
        return false, map:cell(nx, ny)
    end
    self.x = nx
    self.y = ny
    return true
end

return Party
