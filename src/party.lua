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

function Party:turnAround()
    self.dir = direction.opposite(self.dir)
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

-- mark as seen the group's cell and what they see ahead: three columns (left, center and right) until "range" cells.
-- stop on the first wall right in front of them: nobody sees through stone.
function Party:look(map, range)
    map:markSeen(self.x, self.y)
    for ahead = 0, range do
        for side = -1, 1 do
            local x, y = direction.toGrid(self.x, self.y, self.dir, ahead, side)
            map:markSeen(x, y)
        end
        local nextX, nextY = direction.toGrid(self.x, self.y, self.dir, ahead + 1, 0)
        if ahead < range and map:isSolid(nextX, nextY) then
            map:markSeen(nextX, nextY)
            break
        end
    end
end

-- by ahead = 0, range goes through line by line, from the line of the group themselves.
-- after marking the line, check the center cell of the next line (ahead + 1). If it's solid, mark as a wall
-- so it can appear in the minimap and stop with break.
-- the condition ahead < range avoids seeing beyond reach.
return Party
