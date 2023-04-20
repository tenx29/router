--!strict
--[[
    CSRP Fragment Buffer

    Class for buffering CSRP messages that are split into multiple fragments.
]]

local CsrpMessage = require(script.Parent.CsrpMessage)
export type CsrpMessage = CsrpMessage.CsrpMessage

local FragmentBuffer = {}
FragmentBuffer.__index = FragmentBuffer

-- Handle buffer timeout to prevent memory leaks due to incomplete messages.
local function DoTimeout(self: FragmentBuffer)
    -- Begin timeout task
    task.delay(self.Timeout, function()
        -- Throw an error if the buffer is not complete and the timeout has been reached.
        if not self:IsComplete() and tick() > self.CutOffTime then
            -- Clear the buffer to free up memory.
            self.Fragments = {}
            error("Fragment buffer timed out")
        end
    end)
end

-- Creates a new FragmentBuffer.
FragmentBuffer.new = function(timeout: number?)
    local self = setmetatable({}, FragmentBuffer)
    self.Fragments = {}
    self.TotalFragments = 1
    self.Timeout = timeout or 10
    self.CutOffTime = tick() + self.Timeout
    DoTimeout(self)
    return self
end

-- Adds a fragment to the buffer.
FragmentBuffer.Add = function(self: FragmentBuffer, fragment: CsrpMessage)
    assert(self.CutOffTime > tick(), "Attempted to add fragment to timed out buffer")
    local fragmentNumber = fragment.Fragment
    self.TotalFragments = fragment.FragmentCount or self.TotalFragments
    self.Fragments[fragmentNumber] = fragment
    self.CutOffTime = tick() + self.Timeout
    DoTimeout(self)
end

-- Returns a boolean indicating whether the buffer is complete.
FragmentBuffer.IsComplete = function(self: FragmentBuffer): boolean
    return #self.Fragments == self.TotalFragments
end

export type FragmentBuffer = typeof(FragmentBuffer.new())

return FragmentBuffer
