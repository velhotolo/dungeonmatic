local messages = {
    lines = {},
    MAX = 5
}

-- adds a message at the end. If it goes beyond MAX, the older is erased.
function messages.add(text)
    table.insert(messages.lines, text)
    if #messages.lines > messages.MAX then
        table.remove(messages.lines, 1)
    end
end

-- draws the messages, one per line. The old ones turn a bit blurry
function messages.draw(x0, y0, lineHeight)
    for i, text in ipairs(messages.lines) do
        local bright = 0.45 + 0.55 * (i / #messages.lines)
        love.graphics.setColor(0.90 * bright, 0.86 * bright, 0.78 * bright)
        love.graphics.print(text, x0, y0 + (i - 1) * lineHeight)
    end
    love.graphics.setColor(1, 1, 1)
end

return messages
