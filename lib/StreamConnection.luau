--!strict
--[[
    CSRP Message Stream Subscription

    Class for handling the disposal of CSRP message stream subscriptions.
]]

local FragmentBuffer = require(script.Parent.FragmentBuffer)
export type FragmentBuffer = FragmentBuffer.FragmentBuffer

local StreamConnection = {}
StreamConnection.__index = StreamConnection

StreamConnection.new = function(connection: RBXScriptConnection, buffers: {[string]: FragmentBuffer})
    local self = setmetatable({}, StreamConnection)
    self.Connection = connection
    self.Connected = true
    self.Buffers = buffers:: {[string]: FragmentBuffer}
    return self
end

-- Disconnects the subscription and disposes of all buffers.
StreamConnection.Disconnect = function(self: StreamConnection)
    self.Connection:Disconnect()
    for _, buffer in pairs(self.Buffers) do
        buffer:Dispose()
    end
    self.Buffers = {}
    self.Connected = false
end

StreamConnection.__newindex = nil

export type StreamConnection = typeof(StreamConnection.new(game.Close:Connect(function() end), {}))

return StreamConnection
