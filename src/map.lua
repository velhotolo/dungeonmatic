local Map = {}
Map.__index = Map

-- the meaning of the stuff on the other file
Map.TYPES = {
    ["#"] = "wall",
    ["."] = "floor",
    ["S"] = "secret" -- secret passage, looks like a wall until somebody finds it

}

-- creates a map froma list of lines and text
function Map.new(rows)
    local map = { cells = {}, seen = {}, width = 0, height = #rows }
    setmetatable(map, Map)

    for y, row in ipairs(rows) do
        map.cells[y] = {}
        map.seen[y] = {}

        if #row > map.width then
            map.width = #row
        end

        for x = 1, #row do
            local char = row:sub(x, x)
            local kind = Map.TYPES[char]
            if not kind then
                error(("unknown caracter '%s' in line %d, column %d"):format(char, y, x))
            end
            map.cells[y][x] = kind
        end
    end

    return map
end

-- celltype: wall, floor or secret
function Map:cell(x, y)
    local row = self.cells[y]
    if row == nil then
        return "wall"
    end
    return row[x] or "wall"
end

function Map:isFree(x, y)
    return self:cell(x, y) == "floor"
end

-- Should be drawn like a wall (but is not one)? Secret passage.
function Map:isSolid(x, y)
    local kind = self:cell(x, y)
    return kind == "wall" or kind == "secret"
end

function Map:markSeen(x, y)
    local row = self.cells[y]
    if row ~= nil and row[x] ~= nil then
        self.seen[y][x] = true
    end
end

function Map:wasSeen(x, y)
    local row = self.seen[y]
    if row == nil then
        return false
    end
    return row[x] == true
end

return Map
