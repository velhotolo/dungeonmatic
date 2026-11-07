-- a card for each character, created by the system

local rules = require("src.rules")
local utf8 = require("utf8")

local panel = {}

local CARD_COLOR = { 0.16, 0.17, 0.20 }
local BORDER_COLOR = { 0.33, 0.35, 0.40 }
local NAME_COLOR = { 0.85, 0.64, 0.25 }
local TEXT_COLOR = { 0.90, 0.86, 0.78 }
local BAR_COLOR = { 0.55, 0.20, 0.18 }
local EMPTY_COLOR = { 0.25, 0.12, 0.11 }

local function threeLetters(text)
    local fourth = utf8.offset(text, 4)

    if not fourth then
        return text
    end
    return text:sub(1, fourth - 1)
end

local function card(system, c, x, y, w, h, highlight)
    love.graphics.setColor(CARD_COLOR)
    love.graphics.rectangle("fill", x, y, w, h, 4, 4)
    if highlight then
        love.graphics.setColor(NAME_COLOR)
    else
        love.graphics.setColor(BORDER_COLOR)
    end
    love.graphics.rectangle("line", x, y, w, h, 4, 4)
    love.graphics.setColor(NAME_COLOR)
    love.graphics.print(c.name, x + 8, y + 6)
    local lineY = y + 28
    local barWidth = w - 16
    for _, r in ipairs(system.resources) do
        local max = rules.maxOf(system, c, r.id)
        local current = c.resources[r.id] or 0
        love.graphics.setColor(EMPTY_COLOR)
        love.graphics.rectangle("fill", x + 8, lineY + 16, barWidth, 5)
        if max > 0 then
            love.graphics.setColor(BAR_COLOR)
            local filled = barWidth * current / max
            love.graphics.rectangle("fill", x + 8, lineY + 16, filled, 5)
        end
        love.graphics.setColor(TEXT_COLOR)
        love.graphics.print(("%s %d/%d"):format(r.name, current, max), x + 8, lineY)
        lineY = lineY + 26
    end
    local parts = {}
    for _, a in ipairs(system.attributes) do
        local value = c.attributes[a.id]
        table.insert(parts, ("%s %d"):format(threeLetters(a.name), value))
    end
    love.graphics.setColor(TEXT_COLOR)
    love.graphics.print(table.concat(parts, " "), x + 8, lineY + 2)
end
function panel.draw(system, members, x0, y0, w, h, highlight)
    local gap = 8
    local cardWidth = (w - 3 * gap) / 4
    for i, c in ipairs(members) do
        local x = x0 + (i - 1) * (cardWidth + gap)
        card(system, c, x, y0, cardWidth, h, c == highlight)
    end
    love.graphics.setColor(1, 1, 1)
end

return panel
