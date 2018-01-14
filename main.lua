

local soundData
local soundSource

local samples = 44100
local samplerate = 44100
local bits = 16
local channels = 1

local freq = 440

local drawColor

function love.load()
    soundData = love.sound.newSoundData(samples, samplerate, bits, channels)

    makeSinWave()

    soundSource:setVolume(0.5)

    drawColor = {255, 0, 0, 255}
end

function love.keypressed(key, scancode, isrepeat)
    -- Play sound on spacebar
    if key == "space" then
        changeNote()
        soundSource:play()
        drawColor = {0, 255, 0, 255}
    end
end

function love.keyreleased(key, scancode)
    -- Stop sound on spacebar
    if key == "space" then
        --soundSource:stop()
        --changeNote()
        drawColor = {255, 0, 0, 255}        
    end
end

function love.draw()
    love.graphics.setColor(drawColor)

    -- Draw the contents of the SoundData object
    local inc = math.floor(soundData:getSampleCount() / love.graphics.getWidth())
    local currentSample = 0
    for i = 1, love.graphics.getWidth() do
        local yValue = (soundData:getSample(currentSample) + 1) * (love.graphics.getHeight() * 0.5)
        love.graphics.points(i, yValue)
        currentSample = currentSample + inc
    end
end

function changeNote()
    local notes = {200, 250, 300, 400, 800}
    freq = notes[math.random(1, #notes)]

    makeSinWave()
end


function makeSinWave()
    for i = 0, soundData:getSampleCount() - 1 do
        local sampleValue = math.sin(2 * math.pi * freq * i / samplerate)
        soundData:setSample(i, sampleValue)
    end

    attackEnv(500, soundData)
    decayEnv(500, soundData)

    soundSource = love.audio.newSource(soundData)
end

function attackEnv(ms, data)
    local samps = math.floor(samplerate * 0.001 * ms)

    for i = 0, samps do
        local sampleValue = data:getSample(i)
        sampleValue = sampleValue * math.sin(0.5 * math.pi * i / samps)
        data:setSample(i, sampleValue)
    end
end

function decayEnv(ms, data)
    local samps = math.floor(samplerate * 0.001 * ms)
    local lastSample = data:getSampleCount() - 1

    for i = 0, samps do
        local sampleValue = data:getSample(lastSample - i)
        sampleValue = sampleValue * math.sin(0.5 * math.pi * i / samps)
        data:setSample(lastSample - i, sampleValue)
    end
end
