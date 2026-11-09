local charCreator = {}
local menu = require("src.menu")

local COLOR_BG = { 0.55, 0.10, 0.10 }
local COLOR_BTN = { 0.75, 0.15, 0.15 }
local COLOR_HIGH = { 0.95, 0.30, 0.30 }
local COLOR_TEXT = { 1, 1, 1 }
local COLOR_WARN = { 0.9, 0.8, 0.2 } -- Yellow for leftover points

local stats = { str = 1, abi = 1, ["end"] = 1 }

local traits = {
    { name = "Dual Weapon",   cost = 2,  active = false },
    { name = "Range",         cost = 1,  active = false },
    { name = "Defensive",     cost = 2,  active = false },
    { name = "Wizard",        cost = 3,  active = false },
    { name = "Slow",          cost = -1, active = false },
    { name = "Jinxed",        cost = -2, active = false },
    { name = "Not a Fighter", cost = -1, active = false },
    { name = "Cowardice",     cost = -2, active = false }
}

local hitboxes = {}

-- Function to calculate limits
local function getPoints()
    local cost = stats.str + stats.abi + stats["end"]
    local disadv = 0
    for _, t in ipairs(traits) do
        if t.active then
            cost = cost + t.cost
            if t.cost < 0 then
                disadv = disadv + t.cost
            end
        end
    end
    -- Returns maximum points and disadvantages
    return 15 - cost, disadv
end

function charCreator.draw(w, h)
    love.graphics.clear(0.1, 0.05, 0.05)
    hitboxes = {}

    love.graphics.setColor(COLOR_TEXT)
    love.graphics.print("CREATE CHARACTER", 50, 30)

    -- How many points left
    local ptsLeft, currentDisadv = getPoints()
    love.graphics.setColor(COLOR_WARN)
    love.graphics.print("POINTS LEFT: " .. ptsLeft, 50, 60)

    -- When reach disadvantage limit, it tells you discretly
    if currentDisadv <= -3 then
        love.graphics.print("(Disadvantage Limit Reached)", 400, 60)
    end

    local hp = stats["end"] * 5
    local mana = stats.abi * 5
    love.graphics.setColor(COLOR_TEXT)
    love.graphics.print("HP: " .. hp, 300, 30)
    love.graphics.print("MANA: " .. mana, 450, 30)

    local yOffset = 90
    for _, attr in ipairs({ "str", "abi", "end" }) do
        love.graphics.setColor(COLOR_TEXT)
        love.graphics.print(attr:upper() .. ": " .. stats[attr], 50, yOffset)

        -- Buttons +/-
        love.graphics.setColor(COLOR_BTN)
        love.graphics.rectangle("fill", 200, yOffset, 30, 30)
        love.graphics.rectangle("fill", 240, yOffset, 30, 30)
        love.graphics.setColor(COLOR_TEXT)
        love.graphics.print("+", 210, yOffset + 5)
        love.graphics.print("-", 250, yOffset + 5)

        table.insert(hitboxes, { x = 200, y = yOffset, w = 30, h = 30, action = "add_" .. attr })
        table.insert(hitboxes, { x = 240, y = yOffset, w = 30, h = 30, action = "sub_" .. attr })
        yOffset = yOffset + 50
    end

    local traitY = 90
    love.graphics.print("TRAITS:", 400, traitY - 30)
    for i, trait in ipairs(traits) do
        if trait.active then
            love.graphics.setColor(COLOR_HIGH)
        else
            love.graphics.setColor(COLOR_BTN)
        end

        love.graphics.rectangle("fill", 400, traitY, 20, 20)

        love.graphics.setColor(COLOR_TEXT)
        local costStr = trait.cost > 0 and ("(+" .. trait.cost .. ")") or ("(" .. trait.cost .. ")")
        love.graphics.print(trait.name .. " " .. costStr, 430, traitY)

        table.insert(hitboxes, { x = 400, y = traitY, w = 250, h = 20, action = "toggle_" .. i })
        traitY = traitY + 30
    end

    love.graphics.setColor(COLOR_BTN)
    love.graphics.rectangle("fill", 50, h - 80, 150, 40)
    love.graphics.rectangle("fill", 220, h - 80, 150, 40)
    love.graphics.setColor(COLOR_TEXT)
    love.graphics.print("SAVE", 100, h - 70)
    love.graphics.print("CANCEL", 260, h - 70)

    table.insert(hitboxes, { x = 50, y = h - 80, w = 150, h = 40, action = "save" })
    table.insert(hitboxes, { x = 220, y = h - 80, w = 150, h = 40, action = "cancel" })

    love.graphics.setColor(1, 1, 1)
end

function charCreator.mousepressed(x, y, button)
    if button == 1 then
        for _, box in ipairs(hitboxes) do
            if x >= box.x and x <= box.x + box.w and y >= box.y and y <= box.y + box.h then
                if box.action == "cancel" then
                    _G.gameState = "menu"
                elseif box.action == "save" then
                    local activeTraits = {}
                    for _, t in ipairs(traits) do
                        if t.active then
                            local key = t.name:lower():gsub(" ", "_")
                            activeTraits[key] = true
                        end
                    end

                    local newChar = {
                        name = "Custom",
                        class_info = "NEW",
                        attributes = { str = stats.str, abi = stats.abi, ["end"] = stats["end"] },
                        resources = { hp = stats["end"] * 5, mana = stats.abi * 5 },
                        traits = activeTraits
                    }
                    table.insert(menu.characters, newChar)

                    stats = { str = 1, abi = 1, ["end"] = 1 }
                    for _, t in ipairs(traits) do t.active = false end

                    _G.gameState = "menu"
                elseif box.action:sub(1, 4) == "add_" then
                    local ptsLeft, _ = getPoints()
                    -- Just add with points left
                    if ptsLeft > 0 then
                        local attr = box.action:sub(5)
                        stats[attr] = stats[attr] + 1
                    end
                elseif box.action:sub(1, 4) == "sub_" then
                    local attr = box.action:sub(5)
                    if stats[attr] > 1 then
                        stats[attr] = stats[attr] - 1
                    end
                elseif box.action:sub(1, 7) == "toggle_" then
                    local idx = tonumber(box.action:sub(8))
                    local t = traits[idx]

                    -- Try to activate/deactivate
                    t.active = not t.active

                    -- Checks how it would look. If it goes beyond limits, it's stopped right away.
                    local ptsLeft, currentDisadv = getPoints()
                    if ptsLeft < 0 or currentDisadv < -3 then
                        t.active = not t.active
                    end
                end
            end
        end
    end
end

return charCreator
