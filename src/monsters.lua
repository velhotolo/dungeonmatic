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

function monsters.label(group)
    local count = #group.members
    if count == 1 then
        return group.def.name
    end
    return ("%s (%d)"):format(group.def.plural or group.def.name, count)
end

return monsters
