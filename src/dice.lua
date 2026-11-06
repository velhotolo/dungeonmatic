local dice = {}

dice.random = function(faces)
    if love then
        return love.math.random(faces)
    end
    return math.random(faces)
end

function dice.roll(count, faces)
    local results = {}
    for i = 1, count do
        results[i] = dice.random(faces)
    end
    return results
end

function dice.sum(results)
    local total = 0
    for _, value in ipairs(results) do
        total = total + value
    end
    return total
end

function dice.toText(results)
    local parts = {}
    for i, value in ipairs(results) do
        parts[i] = tostring(value)
    end
    return table.concat(parts, ", ")
end

return dice
