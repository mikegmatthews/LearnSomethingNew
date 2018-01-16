-- music.lua
--
-- Author: Mike Matthews
-- Data: 13 Jan 2018
--
-- Description: This provides a music playback engine written for Love2D
--


MusicEngine = {}
MusicEngine.__index = MusicEngine

--- Instantiate a new MusicEngine
function MusicEngine:new(me)
    me = me or {}
    setmetatable(me, self)
    self.notes = {200, 250, 300, 400, 800}
    self.sampleRate = sampleRate or 44100
    self.soundData = love.sound.newSoundData(self.sampleRate, self.sampleRate, 16, 1)
    self.soundSource = love.audio.newSource(self.soundData)
    self.playing = false
    return me
end

--- Start playback
function MusicEngine:start()
    self:nextNote()
    self.playing = true
end

--- Stop playback
function MusicEngine:stop()
    self.playing = false
end

--- Get the current playing state of the engine
--- @return     Boolean value stating whether the enine is currently playing
function MusicEngine:isPlaying()
    return self.playing
end

--- Create a linear amplitude envelope at the beginning of a SoundData buffer
--- @param ms           The number milliseconds the attack should last
--- @param samplerate   The audio sample rate
--- @param data         The SoundData object
local function attackEnv(ms, samplerate, data)
    local samps = math.floor(samplerate * 0.001 * ms)

    for i = 0, samps do
        local sampleValue = data:getSample(i)
        sampleValue = sampleValue * math.sin(0.5 * math.pi * i / samps)
        data:setSample(i, sampleValue)
    end
end

--- Create a linear amplitude envelope at the end of a SoundData buffer
--- @param ms           The number milliseconds the decay should last
--- @param samplerate   The audio sample rate
--- @param data         The SoundData object
local function decayEnv(ms, samplerate, data)
    local samps = math.floor(samplerate * 0.001 * ms)
    local lastSample = data:getSampleCount() - 1

    for i = 0, samps do
        local sampleValue = data:getSample(lastSample - i)
        sampleValue = sampleValue * math.sin(0.5 * math.pi * i / samps)
        data:setSample(lastSample - i, sampleValue)
    end
end

--- Fill a SoundData object buffer with a sin wave at the given frequency
--- @param freq         The frequency of the sin wave
--- @param length       The length of the note in milliseconds
--- @param samplerate   The audio sample rate
--- @param soundData    The SoundData object
local function makeSinWave(freq, length, samplerate, soundData)
    for i = 0, soundData:getSampleCount() - 1 do
        local sampleValue = math.sin(2 * math.pi * freq * i / samplerate)
        soundData:setSample(i, sampleValue)
    end

    attackEnv(math.floor(0.1 * length), samplerate, soundData)
    decayEnv(math.floor(0.5 * length), samplerate, soundData)
end

--- Gets a length for a new note
--- @return     The length for the note in milliseconds
local function newNoteLength()
    local shortest = 150
    local durations = {1, 2, 4, 8}

    return shortest * durations[math.random(1, #durations)]
end

--- Setup and play the next note of music
function MusicEngine:nextNote()
    local freq = self.notes[math.random(1, #self.notes)]
    local noteLength = newNoteLength()    
    self.soundData = love.sound.newSoundData(math.floor(noteLength * 0.001 * self.sampleRate), self.sampleRate, 16, 1)

    makeSinWave(freq, noteLength, self.sampleRate, self.soundData)

    self.soundSource = love.audio.newSource(self.soundData)
    self.soundSource:play()
end

--- Update the Music Engine.  This should be called in love.update
function MusicEngine:update(dt)
    if self.playing and self.soundSource:isPlaying() == false then
        self:nextNote()
    end
end


--- Return the MusicEngine structure
return MusicEngine