local charSelect = {}
local menu = require("src.menu")

local COLOR_BG = { 0.55, 0.10, 0.10 }
local COLOR_BTN_MAIN = { 0.75, 0.15, 0.15 }
local COLOR_BTN_HIGHLIGHT = { 0.95, 0.30, 0.30 }
local COLOR_BTN_SHADOW = { 0.45, 0.05, 0.05 }
local COLOR_TEXT = { 1, 1, 1 }
local COLOR_LIST_BG = { 0.40, 0.05, 0.05 }

local panelW, panelH = 600, 220
local panelX, panelY = 0, 0

local RET_X, RET_Y, RET_W, RET_H = 150, 35, 700, 200
local coterie = {}
local errorMsg = ""
local errorTimer = 0
local selectedIndex = 1

charSelect.roster = {
    { name = "Zarabadias", class_info = "Male Fighter",   attributes = { str = 4, abi = 3, endu = 5 }, resources = { hp = 25, mana = 15 } },
    { name = "Genoveva",   class_info = "Female Fighter", attributes = { str = 5, abi = 2, endu = 5 }, resources = { hp = 25, mana = 10 } },
    { name = "Lysandey",   class_info = "Male Thief",     attributes = { str = 3, abi = 5, endu = 3 }, resources = { hp = 15, mana = 25 } },
    { name = "Nobalah",    class_info = "Female Priest",  attributes = { str = 4, abi = 3, endu = 5 }, resources = { hp = 25, mana = 15 } },
    { name = "Treone",     class_info = "Male Wizard",    attributes = { str = 1, abi = 5, endu = 2 }, resources = { hp = 10, mana = 25 } }
}

-- Adds character to the coterie or shows an error if full
local function addHero(charInfo)
    if #coterie >= 4 then
        errorMsg = "Error: Coterie is full (max 4 heroes)!"
        errorTimer = 3
    else
        table.insert(coterie, charInfo)
    end
end

-- Draws a beveled rectangle with volume
local function drawBeveledRect(x, y, w, h, r, g, b)
    -- Base
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("fill", x, y, w, h)

    local border = 4

    -- Highlights (Top and Left)
    love.graphics.setColor(math.min(r + 0.3, 1), math.min(g + 0.3, 1), math.min(b + 0.3, 1))
    love.graphics.rectangle("fill", x, y, w, border)
    love.graphics.rectangle("fill", x, y, border, h)

    -- Shadows (Bottom and Right)
    love.graphics.setColor(math.max(r - 0.3, 0), math.max(g - 0.3, 0), math.max(b - 0.3, 0))
    love.graphics.rectangle("fill", x, y + h - border, w, border)
    love.graphics.rectangle("fill", x + w - border, y, border, h)
end

-- Draws a standard button
local function drawButton(text, x, y, w, h, isHovered)
    if isHovered then
        love.graphics.setColor(COLOR_BTN_HIGHLIGHT)
    else
        love.graphics.setColor(COLOR_BTN_MAIN)
    end
    love.graphics.rectangle("fill", x, y, w, h)

    love.graphics.setColor(COLOR_BTN_HIGHLIGHT)
    love.graphics.rectangle("fill", x, y, w, 4)

    love.graphics.setColor(COLOR_BTN_SHADOW)
    love.graphics.rectangle("fill", x, y + h - 4, w, 4)

    love.graphics.setColor(COLOR_TEXT)
    local font = love.graphics.getFont()
    local tw, th = font:getWidth(text), font:getHeight()
    love.graphics.print(text, x + (w - tw) / 2, y + (h - th) / 2)
end

-- Update loop for timers
function charSelect.update(dt)
    if errorTimer > 0 then
        errorTimer = errorTimer - dt
    end
end

-- Main draw function for the screen
function charSelect.draw(w, h)
    local mouseX, mouseY = love.mouse.getPosition()

    -- 1. Draw top coterie panel
    drawBeveledRect(RET_X, RET_Y, RET_W, RET_H, 0.85, 0.25, 0.25)

    love.graphics.setColor(COLOR_TEXT)
    for i, char in ipairs(coterie) do
        local tx = RET_X + 20
        local ty = RET_Y + 20 + (i - 1) * 40
        love.graphics.print(char.name .. " (" .. char.class_info .. ")", tx, ty)

        -- 'X' remove button
        local hoverX = mouseX >= tx + 300 and mouseX <= tx + 320 and mouseY >= ty and mouseY <= ty + 20
        love.graphics.setColor(hoverX and COLOR_BTN_HIGHLIGHT or COLOR_BTN_SHADOW)
        love.graphics.rectangle("fill", tx + 300, ty, 20, 20, 4, 4)
        love.graphics.setColor(COLOR_TEXT)
        love.graphics.print("X", tx + 305, ty + 2)
    end

    -- Draw START / CANCEL buttons (only if coterie is full)
    if #coterie == 4 then
        local btnX = RET_X + RET_W - 160
        local startHover = mouseX >= btnX and mouseX <= btnX + 140 and mouseY >= RET_Y + 40 and mouseY <= RET_Y + 80
        local cancelTopHover = mouseX >= btnX and mouseX <= btnX + 140 and mouseY >= RET_Y + 100 and
        mouseY <= RET_Y + 140

        drawButton("START GAME", btnX, RET_Y + 40, 140, 40, startHover)
        drawButton("CANCEL", btnX, RET_Y + 100, 140, 40, cancelTopHover)
    end

    -- Error message
    if errorTimer > 0 then
        love.graphics.setColor(1, 1, 0)
        love.graphics.print(errorMsg, RET_X, RET_Y - 25)
    end

    -- 2. Draw bottom panel (Roster)
    panelX = (w - panelW) / 2
    panelY = h - panelH - 20

    love.graphics.setColor(COLOR_BG)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH)

    love.graphics.setColor(COLOR_TEXT)
    love.graphics.print("ADD CHARACTER", panelX + 20, panelY + 20)

    local btnW, btnH = 200, 40
    local okHover = mouseX >= panelX + 20 and mouseX <= panelX + 20 + btnW and mouseY >= panelY + 80 and
    mouseY <= panelY + 80 + btnH
    local cancelHover = mouseX >= panelX + 20 and mouseX <= panelX + 20 + btnW and mouseY >= panelY + 140 and
    mouseY <= panelY + 140 + btnH

    drawButton("OK", panelX + 20, panelY + 80, btnW, btnH, okHover)
    drawButton("CANCEL", panelX + 20, panelY + 140, btnW, btnH, cancelHover)

    -- Roster list
    local listX, listY, listW, listH = panelX + 250, panelY + 20, 300, 180
    love.graphics.setColor(COLOR_LIST_BG)
    love.graphics.rectangle("fill", listX, listY, listW, listH)

    for i, char in ipairs(charSelect.roster) do
        local itemY = listY + 10 + ((i - 1) * 30)
        if i == selectedIndex then
            love.graphics.setColor(COLOR_BTN_HIGHLIGHT)
        else
            love.graphics.setColor(COLOR_TEXT)
        end
        love.graphics.print(char.name .. "   " .. char.class_info, listX + 15, itemY)
    end
    love.graphics.setColor(1, 1, 1)
end

-- Mouse interaction logic
function charSelect.mousepressed(x, y, button)
    if button ~= 1 then return end

    -- 1. Check 'X' buttons (iterate backwards so removing doesn't break indexes)
    for i = #coterie, 1, -1 do
        local tx = RET_X + 20
        local ty = RET_Y + 20 + (i - 1) * 40
        if x >= tx + 300 and x <= tx + 320 and y >= ty and y <= ty + 20 then
            table.remove(coterie, i)
            return
        end
    end

    -- 2. Check top START and CANCEL buttons
    if #coterie == 4 then
        local btnX = RET_X + RET_W - 160
        -- START GAME
        if x >= btnX and x <= btnX + 140 and y >= RET_Y + 40 and y <= RET_Y + 80 then
            menu.characters = coterie
            _G.gameState = "game"
            return
        end
        -- CANCEL (Coterie)
        if x >= btnX and x <= btnX + 140 and y >= RET_Y + 100 and y <= RET_Y + 140 then
            coterie = {}
            _G.gameState = "menu"
            return
        end
    end

    local btnW, btnH = 200, 40

    -- 3. Bottom CANCEL button (Roster)
    if x >= panelX + 20 and x <= panelX + 20 + btnW and y >= panelY + 140 and y <= panelY + 140 + btnH then
        _G.gameState = "menu"
        return
    end

    -- 4. Bottom OK button (Roster)
    if x >= panelX + 20 and x <= panelX + 20 + btnW and y >= panelY + 80 and y <= panelY + 80 + btnH then
        addHero(charSelect.roster[selectedIndex])
        return
    end

    -- 5. List selection
    local listX, listY, listW = panelX + 250, panelY + 20, 300
    if x >= listX and x <= listX + listW then
        for i in ipairs(charSelect.roster) do
            local itemY = listY + 10 + ((i - 1) * 30)
            if y >= itemY and y <= itemY + 30 then
                selectedIndex = i
            end
        end
    end
end

return charSelect

