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

            id = "hp",
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
    combat = {
        health = "hp",

        initiative = function(c, ctx)
            if slow then
                initiative = ctx.roll(1, 6) + c.attributes.abi - 2
            end
            return ctx.roll(1, 6) + c.attributes.abi
        end,

        attack = function(attacker, defender, situation, ctx)
            local attack = ctx.roll(1, 6) + attacker.attributes.str
            if jinxed then
                jinxed = ctx.roll(2, 6)
                if jinxed < 6 then
                    attack = 0
                end
            end

            if notAfighter then
                attack = ctx.roll(1, 6) + attacker.attributes.str - 2
            end

            if cowardice then
                local cowardice = ctx.roll(1, 6)
                if cowardice > 1 then
                    attack = 0
                end
            end

            if dualWeapon then
                local attack2 = ctx.roll(1, 6) + (attacker.attributes.str - 4)
            end

            local defense = 0
            if situation.defending then
                defense = ctx.roll(1, 6) + (attacker.attributes.endu)
                if defensive then
                    defense = defense + 2
                end
            end

            if attack - defense > 0 then
                local damage = attack - defense
                defender.hp = defender.hp - damage
            end
        end,

        flee = function(members, foes, ctx)
            local best = members[1]
            for _, c in ipairs(members) do
                if c.attributes.abi > best.attributes.abi then
                    best = c
                end
            end

            local need = 1
            if #foes > #members then
                need = 2
            end

            local dif = 12
            local success = ctx.roll(1, 6) + best.attributes.abi

            if success >= dif then
                return success, ("%s: %d"):format(best.name, success)
            end
        end,
    }
}
