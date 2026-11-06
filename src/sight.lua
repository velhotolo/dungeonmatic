-- first person view, drawn only with polygons.
-- no image: each wall is a rectangle (front) or a trapezius (sides)

local direction = require("src.direction")


local sight = {}

sight.DEPTH = 3 -- how mwny cells ahead the coterie sees

-- colours (red, green, blue, com 0 to 1)
local CEILING = { 0.10, 0.09, 0.08 }
local FLOOR = { 0.22, 0.19, 0.15 }
local FRONT = { 0.55, 0.50, 0.42 } -- front wall
local SIDE = { 0.42, 0.38, 0.32 }

-- half width of "plane" k on screen. The plane 0 is the border behind the group.
-- the plane 1 is the border with cell on front; and so on. The farther, the smaller; that's the perspective.

local function halfWidth(w, k)
    return (w / 2) / (k + 1)
end

-- the k plane: the sight center (cx, cy) and halves of width and height
local function plane(x0, y0, w, h, k)
    local cx = x0 + w / 2
    local cy = y0 + h / 2
    local hw = halfWidth(w, k)
    local hh = hw * h / w -- height follows sight proportion
    return cx, cy, hw, hh
end

local function xOnPlane(x0, w, k, edge)
    return x0 + w / 2 + edge * 2 * halfWidth(w, k)
end

local function shade(color, ahead)
    local light = 1 - 0.18 * ahead
    return color[1] * light, color[2] * light, color[3] * light
end

-- 0 x, on screen, on the edge (measured in columns from the center) on plane k.
-- edge = -0.5 is the left border of the coterie's column; +0.5 is the right.
local function frontWall(x0, y0, w, h, ahead, side)
    local _, cy, _, hh = plane(x0, y0, w, h, ahead)
    local xa = xOnPlane(x0, w, ahead, side - 0.5)
    local xb = xOnPlane(x0, w, ahead, side + 0.5)

    love.graphics.setColor(shade(FRONT, ahead))
    love.graphics.rectangle("fill", xa, cy - hh, xb - xa, 2 * hh)
    love.graphics.setColor(0, 0, 0, 0.6) -- black contour half opaque
    love.graphics.rectangle("line", xa, cy - hh, xb - xa, 2 * hh)
end

local function sideWall(x0, y0, w, h, ahead, side)
    local edge
    if side < 0 then
        edge = side + 0.5
    else
        edge = side - 0.5
    end
    local _, cyNear, _, hhNear = plane(x0, y0, w, h, ahead)
    local _, cyFar, _, hhFar = plane(x0, y0, w, h, ahead + 1)
    local xNear = xOnPlane(x0, w, ahead, edge)
    local xFar = xOnPlane(x0, w, ahead + 1, edge)
    local points = {
        xNear, cyNear - hhNear,

        xFar, cyFar - hhFar,

        xFar, cyFar + hhFar,

        xNear, cyNear + hhNear,

    }
    love.graphics.setColor(shade(SIDE, ahead))
    love.graphics.polygon("fill", points)
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.polygon("line", points)
end

-- draws coterie's sight in the area (x0, y0, w, h)
function sight.draw(map, party, x0, y0, w, h)
    love.graphics.setScissor(x0, y0, w, h) -- nothing leaves sight area
    -- ceiling and floor: upper half and bottom half
    love.graphics.setColor(CEILING)
    love.graphics.rectangle("fill", x0, y0, w, h / 2)
    love.graphics.setColor(FLOOR)
    love.graphics.rectangle("fill", x0, y0 + h / 2, w, h / 2)
    for ahead = sight.DEPTH, 0, -1 do
        for _, side in ipairs({ -2, 2, -1, 1 }) do
            local cx, cy = direction.toGrid(party.x, party.y, party.dir, ahead, side)
            if map:isSolid(cx, cy) then
                sideWall(x0, y0, w, h, ahead, side)
            end
        end
        if ahead > 0 then
            for _, side in ipairs({ -2, 2, -1, 1, 0 }) do
                local cx, cy = direction.toGrid(party.x, party.y, party.dir,
                    ahead, side)
                if map:isSolid(cx, cy) then
                    frontWall(x0, y0, w, h, ahead, side)
                end
            end
        end
    end
    love.graphics.setScissor()
    love.graphics.setColor(1, 1, 1)
end

return sight
