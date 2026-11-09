local direction = require("src.direction")
local monsters = require("src.monsters")

local sight = {}
sight.DEPTH = 3

local CEILING = { 0.10, 0.09, 0.08 }
local FLOOR = { 0.22, 0.19, 0.15 }
local FRONT = { 0.55, 0.50, 0.42 }
local SIDE = { 0.42, 0.38, 0.32 }

local imageCache = {}


local function halfWidth(w, k)
    return (w / 2) / (k + 1)
end

local function plane(x0, y0, w, h, k)
    local cx = x0 + w / 2
    local cy = y0 + h / 2
    local hw = halfWidth(w, k)
    local hh = hw * h / w
    return cx, cy, hw, hh
end

local function xOnPlane(x0, w, k, edge)
    return x0 + w / 2 + edge * 2 * halfWidth(w, k)
end

local function shade(color, ahead)
    local light = 1 - 0.18 * ahead
    return color[1] * light, color[2] * light, color[3] * light, 1
end

local function frontWall(x0, y0, w, h, ahead, side)
    local _, cy, _, hh = plane(x0, y0, w, h, ahead)
    local xa = xOnPlane(x0, w, ahead, side - 0.5)
    local xb = xOnPlane(x0, w, ahead, side + 0.5)
    love.graphics.setColor(shade(FRONT, ahead))
    love.graphics.rectangle("fill", xa, cy - hh, xb - xa, 2 * hh)
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("line", xa, cy - hh, xb - xa, 2 * hh)
end

local function sideWall(x0, y0, w, h, ahead, side)
    local edge = side < 0 and (side + 0.5) or (side - 0.5)
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

local function drawMonster(x0, y0, w, h, ahead, side, look, index, count)
    local k = ahead + 0.5
    local _, cy, hw, hh = plane(x0, y0, w, h, k)
    local cellWidth = 2 * hw
    local floorY = cy + hh
    local bodyW = cellWidth * (tonumber(look.width) or 0.6)
    local bodyH = 2 * hh * (tonumber(look.height) or 0.8)
    local offset = (index - (count + 1) / 2) * (cellWidth * 0.4 / math.max(1, count))
    local x = xOnPlane(x0, w, k, side) + offset

    local sprite = nil
    if type(look.image) == "string" then
        if not imageCache[look.image] then
            local ok, img = pcall(love.graphics.newImage, look.image)
            if ok then
                img:setFilter("nearest", "nearest")
                imageCache[look.image] = img
            else
                imageCache[look.image] = "failed"
            end
        end
        if imageCache[look.image] ~= "failed" then
            sprite = imageCache[look.image]
        end
    end

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.ellipse("fill", x, floorY, bodyW / 1.5, bodyH / 8)

    if sprite then
        local imgW = sprite:getWidth()
        local imgH = sprite:getHeight()
        local scaleX = bodyW / imgW
        local scaleY = bodyH / imgH

        love.graphics.setColor(shade({ 1, 1, 1 }, k))
        love.graphics.draw(sprite, x, floorY, 0, scaleX, scaleY, imgW / 2, imgH)
    else
        local y = floorY - bodyH / 2
        local r, g, b, a = shade(look.color or { 0.9, 0.1, 0.1 }, k)
        love.graphics.setColor(r, g, b, a)
        love.graphics.ellipse("fill", x, y, bodyW / 2, bodyH / 2)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.ellipse("line", x, y, bodyW / 2, bodyH / 2)
        local eyeY = floorY - bodyH * 0.6
        local eyeR = math.max(2, bodyW * 0.08)
        love.graphics.setColor(0.95, 0.30, 0.15, 1)
        love.graphics.circle("fill", x - bodyW * 0.15, eyeY, eyeR)
        love.graphics.circle("fill", x + bodyW * 0.15, eyeY, eyeR)
    end
end

local function drawGroupAt(map, party, groups, x0, y0, w, h, ahead, side)
    local gx, gy = direction.toGrid(party.x, party.y, party.dir, ahead, side)
    local group = monsters.at(groups, gx, gy)
    if group == nil then return end
    local count = #group.members
    for i = 1, count do
        drawMonster(x0, y0, w, h, ahead, side, group.def.look, i, count)
    end
end

function sight.draw(map, party, x0, y0, w, h, groups)
    groups = groups or {}
    love.graphics.setScissor(x0, y0, w, h)
    love.graphics.setColor(CEILING)
    love.graphics.rectangle("fill", x0, y0, w, h / 2)
    love.graphics.setColor(FLOOR)
    love.graphics.rectangle("fill", x0, y0 + h / 2, w, h / 2)


    for ahead = sight.DEPTH, 0, -1 do
        for _, side in ipairs({ -2, 2, -1, 1 }) do
            local cx, cy = direction.toGrid(party.x, party.y, party.dir, ahead, side)
            if map:isSolid(cx, cy) then sideWall(x0, y0, w, h, ahead, side) end
        end


        if ahead > 0 then
            for _, side in ipairs({ -1, 1, 0 }) do
                local cx, cy = direction.toGrid(party.x, party.y, party.dir, ahead, side)
                if not map:isSolid(cx, cy) then drawGroupAt(map, party, groups, x0, y0, w, h, ahead, side) end
            end
        end


        if ahead > 0 then
            for _, side in ipairs({ -2, 2, -1, 1, 0 }) do
                local cx, cy = direction.toGrid(party.x, party.y, party.dir, ahead, side)
                if map:isSolid(cx, cy) then frontWall(x0, y0, w, h, ahead, side) end
            end
        end
    end

    love.graphics.setScissor()
    love.graphics.setColor(1, 1, 1)
end

return sight
