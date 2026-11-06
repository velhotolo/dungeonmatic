local sandbox = {}

local function copy(t)
    local c = {}
    for k, v in pairs(t) do
        c[k] = v
    end
    return c
end

function sandbox.defaultEnv()
    local safeMath = copy(math)
    safeMath.random = nil
    safeMath.randomseed = nil
    return {
        math = safeMath,
        string = copy(string),
        table = copy(table),
        pairs = pairs,
        ipairs = ipairs,
        next = next,
        select = select,
        tostring = tostring,
        tonumber = tonumber,
        type = type,
        error = error,
        pcall = pcall,
        unpack = unpack,
    }
end

function sandbox.run(text, name, env)
    if text:byte(1) == 27 then
        return nil, name .. ": bytecode is not accepted"
    end
    local chunk, err = loadstring(text, "=" .. name)
    if not chunk then
        return nil, err
    end
    setfenv(chunk, env or sandbox.defaultEnv())
    local ok, result = pcall(chunk)
    if not ok then
        return nil, result
    end
    return result
end

return sandbox

