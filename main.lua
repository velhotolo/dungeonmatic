function love.load()
    love.graphics.setBackgroundColor(0.09, 0.10, 0.12)
end

function love.leypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function love.draw()
    -- the outline of the areas
    love.graphics.setColor(0.33, 0.35, 0.40)
    love.graphics.rectangle("line", 16, 16, 576, 360)  -- sight
    love.graphics.rectangle("line", 616, 16, 328, 268) -- minimap
    love.graphics.rectangle("line", 16, 392, 928, 108) -- couterie
    love.graphics.rectangle("line", 16, 512, 928, 72)  -- messages

    love.graphics.setColor(0.85, 0.64, 0.25)
    love.graphics.print("sight", 24, 24)
    love.graphics.print("minimap", 624, 24)
    love.graphics.print("coterie", 24, 400)
    love.graphics.print("messages", 24, 520)
end
