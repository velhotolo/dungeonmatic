local rules = require("src.rules")

local monsters = {}

local LETTERS = { "A", "B", "C", "D", "E", "F" }

function monsters.create(system, bestiary, placements)
    local groups = {}
    for i, p in ipairs(placements or {}) do
        local def = bestiary[p.kind]
        if def == nil then
            return nil, ("monsters[%d] from level: '%s' are not in the bestiary"):format(i, tostring(p.kind))
        end

        local group = { kind = p.kind, def = def, x = p.x, y = p.y, members = {} }
        local count = math.min(p.count or 1, #LETTERS)
        for n = 1, count do
            local name = def.name
            if count > 1 then
                name = name .. " " .. LETTERS[n]
            end
            local monster, err = rules.newCharacter(system, name, def.attributes)
            if not monster then
                return nil, err
            end
            table.insert(group.members, monster)
        end
        table.insert(groups, group)
    end
    return groups
end

function monsters.at(groups, x, y)
    for _, group in ipairs(groups) do
        if group.x == x and group.y == y then
            return group
        end
    end
    return nil
end

local function distance(x1, y1, x2, y2)
    return math.abs(x1 - x2) + math.abs(y1 - y2)
end
local function sign(n)
    if n > 0 then
        return 1
    elseif n < 0 then
        return -1
    end
    return 0
end

local function stepToward(group, groups, map, party)
    local dx = sign(party.x - group.x)
    local dy = sign(party.y - group.y)
    local tries
    if math.abs(party.x - group.x) >= math.abs(party.y - group.y) then
        tries = { { dx, 0 }, { 0, dy } }
    else
        tries = { { 0, dy }, { dx, 0 } }
    end
    for _, t in ipairs(tries) do
        local nx, ny = group.x + t[1], group.y + t[2]
        local moves = (t[1] ~= 0 or t[2] ~= 0)
        if moves and map:isFree(nx, ny) and monsters.at(groups, nx, ny) == nil then
            group.x = nx
            group.y = ny
            return true
        end
    end
    return false
end

function monsters.advance(groups, map, party)
    local reached = nil
    for _, group in ipairs(groups) do
        if map:wasSeen(group.x, group.y) then
            group.awake = true
        end
        if group.awake and distance(group.x, group.y, party.x, party.y) > 1 then
            stepToward(group, groups, map, party)
        end
        if reached == nil and distance(group.x, group.y, party.x, party.y) == 1 then
            reached = group
        end
    end
    return reached
end

function monsters.label(group)
    local count = #group.members
    if count == 1 then
        return group.def.name
    end
    return ("%s (%d)"):format(group.def.plural or group.def.name, count)
end

return monsters
