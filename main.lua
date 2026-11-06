-- game's entry point. LOVE looks for this file and load functions

local Map = require("src.map")
local Party = require("src.party")
local direction = require("src.direction")
local minimap = require("src.minimap")
local sight = require("src.sight")
local messages = require("src.messages")

local LEVEL = "level1" --current level
local map              -- current floor
local party            -- the coterie
local font
local RANGE = sight.DEPTH

-- try to walk, if there's a wall, the couterie don't move
local function walk(ahead, side)
    if party:step(map, ahead, side) then
        party:look(map, RANGE)
    end
end


local function turn(toRight)
    if toRight then
        party:turnRight()
    else
        party:turnLeft()
    end
    party:look(map, RANGE)
    messages.add("You turn to " .. direction.NAMES[party.dir] .. ".")
end

function love.load()
    font = love.graphics.newFont(14)
    love.graphics.setBackgroundColor(0.09, 0.10, 0.12)

    -- this will be read by another file in the future
    local level = love.filesystem.load("maps/" .. LEVEL .. ".lua")()
    map = Map.new(level.rows)
    map.name = level.name

    party = Party.new(level.start.x, level.start.y, level.start.dir)
    party:look(map, RANGE)
    messages.add("You enter.. " .. map.name .. ".")
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
    elseif key == "x" then
        party:turnAround()
    elseif key == "escape" then
        love.event.quit()
    end
end

function love.draw()
    sight.draw(map, party, 16, 16, 576, 360)
    love.graphics.setColor(0.33, 0.35, 0.40)
    love.graphics.rectangle("line", 16, 16, 576, 360)
    minimap.draw(map, party, 616, 16, 20)
    love.graphics.setColor(0.90, 0.86, 0.78)
    love.graphics.print(("%s (%d, %d) looking at %s"):format(
        map.name, party.x, party.y, direction.NAMES[party.dir]), 616, 296)
    love.graphics.setColor(0.55, 0.57, 0.62)
    love.graphics.print("W/S or arrows: front and back | A/D: sides", 616, 326)
    love.graphics.print("Q/E or arrows: turn | Esc: quit", 616, 346)
    messages.draw(16, 514, 16)
end
