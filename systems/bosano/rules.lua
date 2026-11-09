local function success(results, target)
    local count = 0
    for _, value in ipairs(results) do
        count = count + value
    end
    return count
end

return {
    id = "bosano",
    name = "Bosano System",
    version = 1,
    attributes = {
        { id = "str",  name = "strength",  min = 1, max = 5 },
        { id = "abi",  name = "ability",   min = 1, max = 5 },
        { id = "endu", name = "endurance", min = 1, max = 5 },

    },

    resources = {
        {
            id = "mana",
            name = "mana",
            max = function(c) return 5 * c.attributes.skill end,
        },
        {

            id = "health",
            name = "hp",
            max = function(c) return 5 * c.attributes.endurance end,
        },
    },

    traits = {
        dual_weapon = { name = "Dual Weapon", cost = 2, desc = "Hits twice" },
        range = { name = "Range", cost = 1, desc = "Hits from a distance" },
        defensive = { name = "Defensive", cost = 2, desc = "Absorb damage when hit" },
        wizard = { name = "Wizard", cost = 3, desc = "Learn spells" }


    },

    test = function(c, attribute, difficulty, ctx)
        local diceNumber = ctx.dice_pool or 1


        local val = c.attributes[attribute] or 0


        local diceResults = ctx.roll(diceNumber, 6)
        local diceTotal = ctx.sum(diceResults)


        local total = diceTotal + val


        local success_check = total >= difficulty

        local text
        if success_check then
            text = ("Total success! Total: %d (Target: %d)"):format(total, difficulty)
        else
            text = ("Miserable failure! Needed %d (Target: %d)"):format(difficulty - total, difficulty)
        end

        return success, text
    end,
    exploration = {
        search = "abi"
    },
}
