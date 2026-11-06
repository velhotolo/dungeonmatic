local sandbox = require("src.sandbox")
local dice = require("src.dice")

local rules = {}

local function findById(list, id)
    for _, item in ipairs(list) do
        if item.id == id then
            return item
        end
    end
    return nil
end

function rules.problems(system)
    local found = {}
    local function problem(text)
        table.insert(found, text)
    end

    if type(system) ~= "table" then
        return { "the file must return a table" }
    end

    if type(system.id) ~= "string" or not system.id:match("^[%w_]+$") then
        problem("id: text just with letters, numbers or _")
    end

    if type(system.name) ~= "string" then
        problem("name: text")
    end

    if type(system.attributes) ~= "table" or #system.attributes == 0 then
        problem("attributes: list must contain at least one attribute")
    else
        for i, a in ipairs(system.attributes) do
            if type(a.id) ~= "string" or type(a.name) ~= "string"
                or type(a.min) ~= "number" or type(a.max) ~= "number"
                or a.min > a.max then
                problem(("attributes[%d]: needs id, name, min and max" .. " (min <= max)"):format(i))
            end
        end
    end

    if type(system.resources) ~= "table" then
        problem("resources: list")
    else
        for i, r in ipairs(system.resources) do
            if type(r.id) ~= "string" or type(r.name) ~= "string"
                or type(r.max) ~= "function" then
                problem(("resources[%d]: needs id, name and a max function"):format(i))
            end
        end
    end

    if type(system.test) ~= "function" then
        problem("test: function (character, attribute, difficulty, ctx)")
    end

    local exploration = system.exploration
    if type(exploration) ~= "table" or type(exploration.search) ~= "string" then
        problem("exploration.search: attribute's id used to look for passages")
    elseif type(system.attributes) == "table"
        and not findById(system.attributes, exploration.search) then
        problem("exploration.search: '" .. exploration.search .. "' it's not one of the attributes")
    end
    return found
end

function rules.load(text, name)
    local system, err = sandbox.run(text, name)
    if not system then
        return nil, err
    end
    local found = rules.problems(system)
    if #found > 0 then
        return nil, name .. ": " .. table.concat(found, "; ")
    end
    return system
end

function rules.maxOf(system, character, resourceId)
    local resource = findById(system.resources, resourceId)
    local ok, value = pcall(resource.max, character)
    if not ok or type(value) ~= "number" then
        return 0
    end
    return value
end

function rules.newCharacter(system, name, values)
    values = values or {}
    for id in pairs(values) do
        if not findById(system.attributes, id) then
            return nil, ("%s: the attribute '%s' doesn't exist in %s"):format(name, id, system.name)
        end
    end

    local character = { name = name, attributes = {}, resources = {} }
    for _, a in ipairs(system.attributes) do
        local value = tonumber(values[a.id]) or a.min
        character.attributes[a.id] = math.max(a.min, math.min(a.max, value))
    end

    for _, r in ipairs(system.resources) do
        character.resources[r.id] = rules.maxOf(system, character, r.id)
    end
    return character
end

function rules.test(system, character, attribute, difficulty)
    local rolls = {}
    local ctx = {
        roll = function(count, faces)
            local results = dice.roll(count, faces)
            local line = ("%dd%d: %s"):format(count, faces, dice.toText(results))
            table.insert(rolls, line)
            return results
        end,
        sum = dice.sum,
    }
    local ok, success, text =
        pcall(system.test, character, attribute, difficulty, ctx)
    if not ok then
        return false, "rules error: " .. tostring(success)
    end
    text = tostring(text or "")
    if #rolls > 0 then
        text = text .. " [" .. table.concat(rolls, " | ") .. "]"
    end
    return success == true, text
end

function rules.best(members, attribute)
    local chosen = nil
    for _, character in ipairs(members) do
        local value = character.attributes[attribute] or 0
        if chosen == nil or value > (chosen.attributes[attribute] or 0) then
            chosen = character
        end
    end
    return chosen
end

return rules
