-- direction.lua the four grid directions and calculations
-- 1 = north, 2 = east, 3 = south, 4 = west (clockwise)
local direction = {}

direction.NAMES = { "north", "east", "south", "west" }

-- the amount x and y change when a step is performed on each direction
-- the y grow downwards, like the lines of a text file
direction.DX = { 0, 1, 0, -1 }
direction.DY = { -1, 0, 1, 0 }

-- turn right: 1->2, 2->3, 3->4, 4->1
function direction.right(dir)
    return (dir % 4) + 1
end

-- turn left: 3/4 turn to the right
function direction.left(dir)
    return ((dir + 2) % 4) + 1
end

-- half turn: 2/4 of turn
function direction.opposite(dir)
    return ((dir + 1) % 4) + 1
end

-- changes a relative position to the group in a grid position
-- ahead: how many cells ahead (negative = behind)
-- side: how many cells to the side (positive = right, negative = left)
function direction.toGrid(x, y, dir, ahead, side)
    local right = direction.right(dir)
    local gx = x + direction.DX[dir] * ahead + direction.DX[right] * side
    local gy = y + direction.DY[dir] * ahead + direction.DY[right] * side
    return gx, gy
end

-- the logic: TUrning right means go to the next direction clockwise. 1, 2, 3, 4 and, after the 4, back to 1.
-- the operator % does this: 4 % $ is 0, 5 % 4 is 1. The formula (dir % 4) + 1 gives us 2, 3, 4, 1 for dir = 1, 2, 3 and 4.
-- to turn left is perform three steps right: ((dir +2) % 4) + 1. Half turn is two steps: ((dir + 1) % 4) + 1.
-- my math skills are lacking, it took a lot of time to figure this out

return direction
