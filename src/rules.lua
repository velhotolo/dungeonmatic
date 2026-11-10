local sandbox = require("src.sandbox")
local dice = require("src.dice")
local rules = {}
.
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
        return { "o arquivo precisa retornar uma tabela" }
    end
    if type(system.id) ~= "string" or not system.id:match("^[%w_]+$") then
        problem("id: texto só com letras, números ou _")
    end
    if type(system.name) ~= "string" then
        problem("name: texto")
    end
    if type(system.attributes) ~= "table" or #system.attributes == 0 then
        problem("attributes: lista com pelo menos um atributo")
    else
        for i, a in ipairs(system.attributes) do
            if type(a.id) ~= "string" or type(a.name) ~= "string"
                or type(a.min) ~= "number" or type(a.max) ~= "number"
                or a.min > a.max then
                problem(("attributes[%d]: precisa de id, name, min e max"
                    .. " (min <= max)"):format(i))
            end
        end
    end
    if type(system.resources) ~= "table" then
        problem("resources: lista (pode ser vazia)")
    else
        for i, r in ipairs(system.resources) do
            if type(r.id) ~= "string" or type(r.name) ~= "string"
                or type(r.max) ~= "function" then
                problem(("resources[%d]: precisa de id, name e uma função max")
                    :format(i))
            end
        end
    end
    if type(system.test) ~= "function" then
        problem("test: função (personagem, atributo, dificuldade, ctx)")
    end
    local exploration = system.exploration
    if type(exploration) ~= "table" or type(exploration.search) ~= "string" then
        problem("exploration.search: id do atributo usado para procurar passagens")
    elseif type(system.attributes) == "table"
        and not findById(system.attributes, exploration.search) then
        problem("exploration.search: '" .. exploration.search
            .. "' não é um dos atributos")
    end
    local combat = system.combat
    if type(combat) ~= "table" then
        problem("combat: tabela com health, initiative, attack e flee")
    else
        if type(combat.health) ~= "string" then
            problem("combat.health: id do recurso que derruba quem chega a 0")
        elseif type(system.resources) == "table"
            and not findById(system.resources, combat.health) then
            problem("combat.health: '" .. combat.health .. "' não é um dos recursos")
        end
        if type(combat.initiative) ~= "function" then
            problem("combat.initiative: função (personagem, ctx)")
        end
        if type(combat.attack) ~= "function" then
            problem("combat.attack: função (atacante, alvo, situação, ctx)")
        end
        if type(combat.flee) ~= "function" then
            problem("combat.flee: função (aventureiros, monstros, ctx)")
        end
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
            return nil, ("%s: o atributo '%s' não existe em %s")
                :format(name, id, system.name)
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

local function newCtx()
    local ctx = { rolls = {}, sum = dice.sum }
    ctx.roll = function(count, faces)
        local results = dice.roll(count, faces)
        local line = ("%dd%d: %s"):format(count, faces, dice.toText(results))
        table.insert(ctx.rolls, line)
        return results
    end
    return ctx
end

local function withRolls(text, ctx)
    text = tostring(text or "")
    if #ctx.rolls > 0 then
        text = text .. " [" .. table.concat(ctx.rolls, " | ") .. "]"
    end
    return text
end

function rules.test(system, character, attribute, difficulty)
    local ctx = newCtx()
    local ok, success, text =
        pcall(system.test, character, attribute, difficulty, ctx)
    if not ok then
        return false, "erro na regra: " .. tostring(success)
    end
    return success == true, withRolls(text, ctx)
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

function rules.health(system, character)
    return character.resources[system.combat.health] or 0
end

function rules.damage(system, character, amount)
    local id = system.combat.health
    local value = math.max(0, (character.resources[id] or 0) - amount)
    character.resources[id] = value
    character.down = (value <= 0)
end

function rules.heal(system, character, amount)
    local id = system.combat.health
    local max = rules.maxOf(system, character, id)
    local value = math.min(max, (character.resources[id] or 0) + amount)
    character.resources[id] = value
    character.down = (value <= 0)
end

function rules.initiative(system, character)
    local ok, value = pcall(system.combat.initiative, character, newCtx())
    if not ok or type(value) ~= "number" then
        return 0
    end
    return value
end

function rules.attack(system, attacker, defender, situation)
    local ctx = newCtx()
    local ok, damage, text =
        pcall(system.combat.attack, attacker, defender, situation or {}, ctx)
    if not ok then
        return 0, "erro na regra: " .. tostring(damage)
    end
    if type(damage) ~= "number" or damage < 0 then
        damage = 0
    end
    return math.floor(damage), withRolls(text, ctx)
end

function rules.flee(system, members, foes)
    local ctx = newCtx()
    local ok, success, text = pcall(system.combat.flee, members, foes, ctx)
    if not ok then
        return false, "erro na regra: " .. tostring(success)
    end
    return success == true, withRolls(text, ctx)
end

return rules

