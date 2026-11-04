-- game's entry point. LOVE looks for this file and load functions

local Map = require("src.map")
local Party = require("src.party")
local direction = require("src.direction")
local minimap = require("src.minimap")

local LEVEL = "level1" --current level
local maps             -- current floor
local party            -- the coterie

-- try to walk, if there's a wall, the couterie don't move
local function walk(ahead, side)
    party:step(map, ahead, side)
end

local function turn(toRight)
    if toRight then
        party:turnRight()
    else
        party:turnLeft()
    end
end

function love.load()
    love.graphics.setBackgroundColor(0.09, 0.10, 0.12)

    -- this will be read by another file in the future
    local level = love.filesystem.load("maps/" .. LEVEL .. ".lua")()
    map = Map.new(level.rows)
    map.name = level.name

    party = Party.new(x, y, dir)
end

function love.keypressed(key)
    if key == "w" or key == "up" then
        walk(1, 0)
    elseif key == "s" or key == "down" then
        walk(-1, 0)
    elseif key == "a" then
        walk(0, -1)
    elseif key == "d" then
        walk(0, 1)
    elseif key == "q" or key == "left" then
        turn(false)
    elseif key == "e" or key == "right" then
        turn(true)
    elseif key == "escape" then
        love.event.quit()
    end
end

function love.draw()
    minimap.draw(map, party, 616, 16, 20)

    love.graphics.setColor(0.90, 0.86, 0.78)
    love.graphics.print(("%s, %d, %d, looking at %s"):format(
        map.name, party.x, party.y, direction.NAMES[party.dir]), 616, 296)
end
