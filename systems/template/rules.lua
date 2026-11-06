-- Empty template: copy this folder to systems/<your_system>/ and fill it out.
-- The engine (src/rules.lua) checks every field upon loading and tells you what's missing.
--
-- Available in here: math (without random), string, table, pairs, ipairs,
-- next, select, tostring, tonumber, type, error, pcall, unpack.
-- Rolls: ctx.roll(amount, faces) returns the list of results;
-- ctx.sum(list) sums the list. Always use ctx: this way the rolls
-- will show up in the game's messages.
return {
    id = "my_system", -- only letters, numbers and _ ; same as the folder name
    name = "My system",
    version = 1,

    -- Attributes: each with id, name, min and max.
    attributes = {
        -- { id = "strength", name = "Strength", min = 1, max = 10 },
    },

    -- Resources: values that go up and down (health, mana...).
    -- max receives the character (c) and returns a number.
    -- c.attributes.<id> holds the value of each attribute.
    resources = {
        -- {
        --     id = "health", name = "Health Points",
        --     max = function(c) return 10 + c.attributes.strength end,
        -- },
    },

    -- Attribute test. Receives the character, the attribute id, the difficulty
    -- (a number decided by the map or the game) and ctx.
    -- Returns: true or false, and a short text for the messages.
    test = function(c, attribute, difficulty, ctx)
        -- local d = ctx.roll(1, 20)[1]
        -- return d + c.attributes[attribute] >= difficulty, "rolled " .. d
        return false, "test not written yet"
    end,

    -- Which attribute the game uses in each exploration action.
    exploration = {
        search = "", -- the id of one of the attributes above
    },
}

