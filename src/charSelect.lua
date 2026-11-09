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
local charTable = {}

charSelect.roster = {
    { name = "Zarabadias", class_info = "Male Fighter",   attributes = { str = 4, abi = 3, endu = 5 }, resources = { hp = 25, mana = 15 } },
    { name = "Genoveva",   class_info = "Female Fighter", attributes = { str = 5, abi = 2, endu = 5 }, resources = { hp = 25, mana = 10 } },
    { name = "Lysandey",   class_info = "Male Thief",     attributes = { str = 3, abi = 5, endu = 3 }, resources = { hp = 15, mana = 25 } },
    { name = "Nobalah",    class_info = "Female Priest",  attributes = { str = 4, abi = 3, endu = 5 }, resources = { hp = 25, mana = 15 } },
    { name = "Treone",     class_info = "Male Wizard",    attributes = { str = 1, abi = 5, endu = 2 }, resources = { hp = 10, mana = 25 } }
}
local selectedIndex = 1

local function drawButton(text, x, y, w, h, isHovered)
    if isHovered then
        love.graphics.setColor(COLOR_BTN_HIGHLIGHT)
    else
        love.graphics.setColor(COLOR_BTN_MAIN)
    end
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(COLOR_BTN_HIGHLIGHT)
    love.graphics.rectangle("fill", x, y, w, 4)
    love.graphics.rectangle("fill", 150, 35, 700, 200)
    love.graphics.setColor(COLOR_BTN_SHADOW)
    love.graphics.rectangle("fill", x, y + h - 4, w, 4)
    love.graphics.setColor(COLOR_TEXT)
    local font = love.graphics.getFont()
    local tw, th = font:getWidth(text), font:getHeight()
    love.graphics.print(text, x + (w - tw) / 2, y + (h - th) / 2)
end




function charSelect.draw(w, h)
    panelX = (w - panelW) / 2
    panelY = h - panelH - 20
    local mouseX, mouseY = love.mouse.getPosition()

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

function charSelect.mousepressed(x, y, button)
    if button == 1 then
        local btnW, btnH = 200, 40
        if x >= panelX + 20 and x <= panelX + 20 + btnW and y >= panelY + 140 and y <= panelY + 140 + btnH then
            _G.gameState = "menu" -- CANCEL
        end
        if x >= panelX + 20 and x <= panelX + 20 + btnW and y >= panelY + 80 and y <= panelY + 80 + btnH then
            table.insert(menu.characters, charSelect.roster[selectedIndex])
            _G.gameState = "menu"
        end

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
end

return charSelect
