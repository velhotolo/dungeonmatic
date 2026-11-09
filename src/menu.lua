local menu = {}


local COLOR_BTN_MAIN = { 0.75, 0.15, 0.15 }   -- Main red
local COLOR_BTN_HIGHLIGHT = { 0.95, 0.30, 0.30 }
local COLOR_BTN_SHADOW = { 0.45, 0.05, 0.05 } -- Base shadow
local COLOR_TEXT = { 1, 1, 1 }                -- White text
local COLOR_ERROR = { 0.9, 0.8, 0.2 }         -- Yellow

local btnWidth = 400
local btnHeight = 50
local spacing = 15
local startY = 150
local startX = 0

-- Char list, error message
menu.characters = {}
menu.errorMessage = ""
menu.errorTimer = 0

-- BG load
local bgImage = love.graphics.newImage("assets/bg.jpg")

-- Buttons and their actions
local buttons = {
    {
        text = "START GAME",
        action = function()
            if #menu.characters > 0 then
                _G.gameState = "playing" -- Changes global state to start the game
                menu.errorMessage = ""
            else
                menu.errorMessage = "Please create or add a character to start."
                menu.errorTimer = 3 -- Time of message on screen
            end
        end
    },
    { text = "ADD CHARACTER",    action = function() _G.gameState = "char_select" end },
    { text = "CREATE CHARACTER", action = function() _G.gameState = "char_create" end },
    { text = "QUIT GAME",        action = function() love.event.quit() end }
}

-- Update the time of error message to disappear
function menu.update(dt)
    if menu.errorTimer > 0 then
        menu.errorTimer = menu.errorTimer - dt
        if menu.errorTimer <= 0 then
            menu.errorMessage = ""
        end
    end
end

function menu.draw(w, h)
    -- 1. Stretches BG to fit the window
    love.graphics.setColor(1, 1, 1, 1)
    local scaleX = w / bgImage:getWidth()
    local scaleY = h / bgImage:getHeight()
    love.graphics.draw(bgImage, 0, 0, 0, scaleX, scaleY)

    -- 2. Subtle black filter to help read the buttons
    love.graphics.setColor(0, 0, 0, 0.45)
    love.graphics.rectangle("fill", (w - btnWidth - 40) / 2, startY - 20, btnWidth + 40,
        (#buttons * (btnHeight + spacing)) + 40)

    local font = love.graphics.getFont()
    startX = (w - btnWidth) / 2

    local mouseX, mouseY = love.mouse.getPosition()

    -- 3. Draws button list
    for i, btn in ipairs(buttons) do
        local y = startY + (i - 1) * (btnHeight + spacing)

        local isHovered = mouseX >= startX and mouseX <= startX + btnWidth and
            mouseY >= y and mouseY <= y + btnHeight

        if isHovered then
            love.graphics.setColor(COLOR_BTN_HIGHLIGHT)
        else
            love.graphics.setColor(COLOR_BTN_MAIN)
        end
        love.graphics.rectangle("fill", startX, y, btnWidth, btnHeight)

        love.graphics.setColor(COLOR_BTN_HIGHLIGHT)
        love.graphics.rectangle("fill", startX, y, btnWidth, 4)

        love.graphics.setColor(COLOR_BTN_SHADOW)
        love.graphics.rectangle("fill", startX, y + btnHeight - 4, btnWidth, 4)

        love.graphics.setColor(COLOR_TEXT)
        local textW = font:getWidth(btn.text)
        local textH = font:getHeight()
        love.graphics.print(btn.text, startX + (btnWidth - textW) / 2, y + (btnHeight - textH) / 2)
    end

    -- Message if the player tries to go to the game without chars
    if menu.errorMessage ~= "" then
        love.graphics.setColor(COLOR_ERROR)
        local errW = font:getWidth(menu.errorMessage)
        local errY = startY + (#buttons * (btnHeight + spacing)) + 20
        love.graphics.print(menu.errorMessage, (w - errW) / 2, errY)
    end

    love.graphics.setColor(1, 1, 1)
end

-- Click handler
function menu.mousepressed(x, y, button)
    if button == 1 then
        for i, btn in ipairs(buttons) do
            local btnY = startY + (i - 1) * (btnHeight + spacing)
            if x >= startX and x <= startX + btnWidth and
                y >= btnY and y <= btnY + btnHeight then
                if btn.action then btn.action() end
            end
        end
    end
end

return menu
