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
        { id = "brute",  name = "strength",  min = 1, max = 5 },
        { id = "skill",  name = "abilitiy",  min = 1, max = 5 },
        { id = "endure", name = "endurance", min = 1, max = 5 },

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
            max = function(c) return 5 * c.attributes.endure end,
        },
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
        search = "skill"
    },
}
