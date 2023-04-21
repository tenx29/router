--!strict
--[[
    CSRP Fragment Buffer

    Class for buffering CSRP messages that are split into multiple fragments.
]]

local CsrpMessage = require(script.Parent.CsrpMessage)
export type CsrpMessage = CsrpMessage.CsrpMessage

local FragmentBuffer = {}
FragmentBuffer.__index = FragmentBuffer

-- Creates a new FragmentBuffer.
FragmentBuffer.new = function(timeout: number?): FragmentBuffer
    local self = setmetatable({}, FragmentBuffer)
    self.Fragments = {}
    self.TotalFragments = 1
    self.Timeout = timeout or 10
    self.CutOffTime = tick() + self.Timeout
    local _timeoutEvent = Instance.new("BindableEvent")
    self.TimedOut = _timeoutEvent.Event

    local function throwTimeoutError(err: string)
        _timeoutEvent:Fire(err)
    end

    self.DoTimeout = function(obj: FragmentBuffer)
        -- Begin timeout task
        task.delay(obj.Timeout, function(cutOffTime: number)
            -- If the cut off time has changed, the buffer has been reset and this timeout task should be cancelled.
            if obj.CutOffTime ~= cutOffTime then
                return
            end
            -- Throw an error if the buffer is not complete and the timeout has been reached.
            -- If the CutOffTime 0 or negative, the buffer has been disabled and no error should be thrown.
            if obj.CutOffTime > 0 and not obj:IsComplete() and tick() > obj.CutOffTime then
                -- Clear the buffer to free up memory.
                obj.Fragments = {}
                throwTimeoutError()
            end
        end, obj.CutOffTime)
    end

    self:DoTimeout()
    return self
end

-- Adds a fragment to the buffer.
FragmentBuffer.Add = function(self: FragmentBuffer, fragment: CsrpMessage)
    assert(self.CutOffTime > tick(), "Attempted to add fragment to timed out buffer")
    local fragmentNumber = fragment.Fragment or 1
    self.TotalFragments = fragment.FragmentCount or self.TotalFragments
    self.Fragments[fragmentNumber] = fragment
    self.CutOffTime = tick() + self.Timeout
    self:DoTimeout()
end

-- Returns a boolean indicating whether the buffer is complete.
FragmentBuffer.IsComplete = function(self: FragmentBuffer): boolean
    return #self.Fragments == self.TotalFragments
end

-- Disable the buffer
FragmentBuffer.Disable = function(self: FragmentBuffer)
    self.CutOffTime = 0
end

-- Dispose of the buffer to free up memory.
FragmentBuffer.Dispose = function(self: FragmentBuffer)
    self:Disable()
    self.Fragments = {}
end

export type FragmentBuffer = typeof(FragmentBuffer.new())

return FragmentBuffer
