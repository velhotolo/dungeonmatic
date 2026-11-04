-- the map from above
local direction = require("src.direction")

local minimap = {}

local FLOOR_COLOR = { 0.30, 0.27, 0.22 }
local WALL_COLOR = { 0.62, 0.45, 0.45 }
local PARTY_COLOR = { 0.85, 0.64, 0.25 }

-- a triangle on the center of the group's cell, pointing to where they look
local function drawParty(party, x0, y0, size)
    local cx = x0 + (party.x - 0.5) * size -- cell center, in pixels
    local cy = y0 + (party.y - 0.5) * size
    local d = party.dir
    local l = direction.left(d)
    local r = direction.right(d)
    local radius = size * 0.4
    local back = radius * 0.8

    -- point: ahead of the center
    local tipX = cx + direction.DX[d] * radius
    local tipY = cy + direction.DY[d] * radius

    -- back edge to the left and back edge to the right
    local leftX = cx + (direction.DX[l] - direction.DX[d]) * back
    local leftY = cy + (direction.DY[l] - direction.DY[d]) * back
    local rightX = cx + (direction.DX[r] - direction.DX[d]) * back
    local rightY = cy + (direction.DY[r] - direction.DY[d]) * back
    love.graphics.setColor(PARTY_COLOR)
    love.graphics.polygon("fill", tipX, tipY, leftX, leftY, rightX, rightY)
end

function minimap.draw(map, party, x0, y0, size)
    for y = 1, map.height do
        for x = 1, map.width do
            if map:isSolid(x, y) then
                love.graphics.setColor(WALL_COLOR)
            else
                love.graphics.setColor(FLOOR_COLOR)
            end
            love.graphics.rectangle("fill",
                x0 + (x - 1) * size, y0 + (y - 1) * size,
                size - 1, size - 1)
        end
    end
    drawParty(party, x0, y0, size)
    love.graphics.setColor(1, 1, 1)
end

return minimap

-- colours stay outside the function, because they're the same in each frame.
-- the function goes through each cell and draws each one like e filled frame
-- the math behind it: The cell (x, y) beings at x0 + (x -1) * size. The -1 exists because the grid
-- starts in 1 and the screen at 0: the cell n 1 stays exactly at x0.
-- square side is size - 1: the pixel leftover turns into a dark line between cells.
-- love.graphics.SetColor directly accepts a color table: setColor (WALL_COLOR) (this is magic)
-- in the end, colour comes back to white. It will allow freedom to draw something better in the future.
