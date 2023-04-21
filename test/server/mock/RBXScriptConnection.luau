--!strict
local RBXScriptConnection = {}
RBXScriptConnection.__index = RBXScriptConnection

RBXScriptConnection.new = function(callback: (...any?) -> ()?)
    local self = setmetatable({}, RBXScriptConnection)
    self.Connected = true
    self._callback = callback
    return self
end

RBXScriptConnection.Disconnect = function(self: RBXScriptConnection)
    self._callback = nil
    self.Connected = false
end

RBXScriptConnection.__call = function(self: RBXScriptConnection, ...)
    if self._callback then
        self._callback(...)
    end
end

export type RBXScriptConnection = typeof(RBXScriptConnection.new(function() end))

return RBXScriptConnection
