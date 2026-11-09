_G.gameState = "menu"
_G.showDebug = false

local menu = require("src.menu")
local charSelect = require("src.charSelect")
local charCreator = require("src.charCreator")
local Map = require("src.map")
local Party = require("src.party")
local direction = require("src.direction")
local minimap = require("src.minimap")
local sight = require("src.sight")
local messages = require("src.messages")
local sandbox = require("src.sandbox")
local rules = require("src.rules")
local panel = require("src.panel")
local monsters = require("src.monsters")


local LEVEL = "level1"
local map
local party
local font
local system
local bestiary
local groups
local RANGE = sight.DEPTH
local SYSTEM = "bosano"
local lastActor

local mx, my = love.mouse.getPosition()
love.graphics.setColor(0, 1, 0) -- Shiny green for the aim that calculates coordinates
love.graphics.print("X: " .. mx .. " | Y: " .. my, mx + 15, my + 15)


local function readData(path)
    local text = assert(love.filesystem.read(path), "can't find it " .. path)
    return assert(sandbox.run(text, path, {}))
end

local function loadSystem(name)
    local path = "systems/" .. name .. "/rules.lua"
    local text = assert(love.filesystem.read(path), "can't find it " .. path)
    return assert(rules.load(text, path))
end

local function walk(ahead, side)
    local tx, ty = direction.toGrid(party.x, party.y, party.dir, ahead, side)
    local group = monsters.at(groups, tx, ty)
    if group then
        messages.add("On the way: " .. monsters.label(group) .. ".")
    elseif party:step(map, ahead, side) then
        party:look(map, RANGE)
    else
        messages.add("You hit the wall.")
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

local function search()
    local attribute = system.exploration.search
    local who = rules.best(party.members, attribute)
    local fx, fy = direction.toGrid(party.x, party.y, party.dir, 1, 0)
    local success, text = rules.test(system, who, attribute, map.secretDifficulty)
    lastActor = who
    if success and map:cell(fx, fy) == "secret" then
        map:set(fx, fy, "floor")
        messages.add(who.name .. " finds a secret passage! " .. text)
        party:look(map, RANGE)
    else
        messages.add(who.name .. " search but finds nothing. " .. text)
    end
end



function love.load()
    font = love.graphics.newFont(14)
    love.graphics.setFont(font)
    love.graphics.setBackgroundColor(0.09, 0.10, 0.12)

    system = loadSystem(SYSTEM)
    local level = readData("maps/" .. LEVEL .. ".lua")
    map = Map.new(level.rows)
    map.name = level.name
    map.secretDifficulty = level.secretDifficulty or 1


    party = Party.new(level.start.x, level.start.y, level.start.dir)
    party:look(map, RANGE)


    bestiary = readData("systems/" .. SYSTEM .. "/bestiary.lua")
    groups = assert(monsters.create(system, bestiary, level.monsters))
    messages.add("You enter in " .. map.name .. ".")
end

function love.update(dt)
    if _G.gameState == "menu" then
        menu.update(dt)
    elseif _G.gameState == "playing" then
        if #party.members == 0 and menu.characters then
            for _, charData in ipairs(menu.characters) do
                local c = assert(rules.newCharacter(system, charData.name, charData.attributes))

                -- Get exact values for HP and Mana
                c.resources = {
                    hp = charData.resources.hp,
                    mana = charData.resources.mana
                }

                -- Save maximum values
                c.maxResources = {
                    hp = charData.resources.hp,
                    mana = charData.resources.mana
                }

                table.insert(party.members, c)
            end
        end
    end
end

function love.draw()
    local w, h = love.graphics.getDimensions()

    if _G.gameState == "menu" then
        menu.draw(w, h)
    elseif _G.gameState == "char_select" then
        if charSelect and charSelect.draw then charSelect.draw(w, h) end
    elseif _G.gameState == "char_create" then
        if charCreator and charCreator.draw then charCreator.draw(w, h) end
    elseif _G.gameState == "playing" then
        -- Draws the game
        sight.draw(map, party, 16, 16, 576, 360, groups)

        if #party.members > 0 then
            panel.draw(system, party.members, 16, 380, 576, 120, party.members[1])
        end

        love.graphics.setColor(0.33, 0.35, 0.40)
        love.graphics.rectangle("line", 16, 16, 576, 360)
        minimap.draw(map, party, 616, 16, 20, groups)

        love.graphics.setColor(0.90, 0.86, 0.78)
        love.graphics.print(("%s (%d, %d) looking at %s"):format(
            map.name, party.x, party.y, direction.NAMES[party.dir]), 616, 296)

        love.graphics.setColor(0.55, 0.57, 0.62)
        love.graphics.print("W/S or arrows: front and back | A/D: sides", 616, 326)
        love.graphics.print("Q/E or arrows: turn | Esc: quit", 616, 346)
        love.graphics.print("   Bosano RPG System", 616, 366)

        messages.draw(16, 514, 16)
    end

    -- This aim helps me find out the coordinates of windows, buttons and whatnot. I was dumb and sketched everything on paper, so I don't have a layout
    -- with digital coordinates.
    if _G.showDebug then
        local mx, my = love.mouse.getPosition()
        love.graphics.setColor(0, 1, 0, 1)
        love.graphics.line(mx - 15, my, mx + 15, my)
        love.graphics.line(mx, my - 15, mx, my + 15)
        local font = love.graphics.getFont()
        love.graphics.print("X: " .. mx, mx + 20, my - 10)
        love.graphics.print("Y: " .. my, mx + 20, my + 10)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if _G.gameState == "menu" then
        menu.mousepressed(x, y, button)
    elseif _G.gameState == "char_select" then
        if charSelect and charSelect.mousepressed then charSelect.mousepressed(x, y, button) end
    elseif _G.gameState == "char_create" then
        if charCreator and charCreator.mousepressed then charCreator.mousepressed(x, y, button) end
    end
end

function love.keypressed(key, scancode, isrepeat)
    if key == "f1" then
        _G.showDebug = not _G.showDebug
    end

    if _G.gameState == "playing" then
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
            _G.gameState = "menu"
        end
    end
end
