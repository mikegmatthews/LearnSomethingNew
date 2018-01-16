
local me = require('musicengine')

local musicEngine

local sampleRate = 44100

local drawColor

function love.load()
    musicEngine = me:new()

    drawColor = {255, 0, 0, 255}
end

function love.keypressed(key, scancode, isrepeat)
    -- Play sound on spacebar
    if key == "space" and musicEngine:isPlaying() then
        musicEngine:stop()
    elseif key == "space" then
        musicEngine:start()
    elseif key == "escape" then
        love.window.close()
    end
end

function love.keyreleased(key, scancode)

end

function love.update(dt)
    musicEngine:update(dt)
    if musicEngine:isPlaying() then
        drawColor = {0, 255, 0, 255}
    else
        drawColor = {255, 0, 0, 255}
    end
end

function love.draw()
    love.graphics.setColor(drawColor)
--[[
    -- Draw the contents of the SoundData object 
    local inc = math.floor(soundData:getSampleCount() / love.graphics.getWidth())
    local currentSample = 0
    for i = 1, love.graphics.getWidth() do
        local yValue = (soundData:getSample(currentSample) + 1) * (love.graphics.getHeight() * 0.5)
        love.graphics.points(i, yValue)
        currentSample = currentSample + inc
    end
--]]
end



