--!strict
--[[
    CSRP Message Stream

    Class for handling CSRP message streams.
]]
local MessagingService = game:GetService("MessagingService")

local RouterLib = script.Parent
local CsrpMessage = require(RouterLib.CsrpMessage)
local CsrpMessageBuilder = require(RouterLib.CsrpMessageBuilder)
export type CsrpMessage = CsrpMessage.CsrpMessage
export type CsrpMessageBuilder = CsrpMessageBuilder.CsrpMessageBuilder

local FragmentBuffer = require(RouterLib.FragmentBuffer)
local StreamConnection = require(RouterLib.StreamConnection)
export type FragmentBuffer = FragmentBuffer.FragmentBuffer
export type StreamConnection = StreamConnection.StreamConnection

local Fragmenter = require(RouterLib.Fragmenter)
local Router = require(RouterLib.Router)

local MessageStream = {}
MessageStream.__index = MessageStream

local DEFAULT_MESSAGE_STREAM_TOPIC = "CSRP_GLOBAL"

MessageStream.new = function(topic: string?)
    local self = setmetatable({}, MessageStream)
    self.Topic = topic or DEFAULT_MESSAGE_STREAM_TOPIC
    return self
end

MessageStream.Send = function(self: MessageStream, message: CsrpMessage)
    local fragments = Fragmenter.FragmentMessage(message)
    for _, fragment in ipairs(fragments) do
        -- If sending a fragment fails, retry 10 times with a 1 second delay.
        local success = false
        local err = nil
        for _ = 1, 10 do
            success, err = pcall(function()
                MessagingService:PublishAsync(self.Topic, tostring(fragment))
            end)
            if success then
                break
            end
            task.wait(1)
        end
        if not success then
            error(err)
        end
    end
end

-- Buffers a fragment and returns a boolean indicating whether the buffer is complete.
local function BufferFragment(connection: StreamConnection, fragment: CsrpMessage): boolean
    local interactionId = fragment.InteractionId
    if not connection.Buffers[interactionId] then
        local buffer = FragmentBuffer.new()
        connection.Buffers[interactionId] = buffer
        buffer.TimedOut:Connect(function(err: string?)
            FragmentBuffer:Dispose()
            error(err or "Fragment buffer timed out.")
        end)
    end
    connection.Buffers[interactionId]:Add(fragment)
    return connection.Buffers[interactionId]:IsComplete()
end

-- Subscribes to the message stream and returns a connection.
MessageStream.Subscribe = function(self: MessageStream, callback: (CsrpMessage, number) -> nil): StreamConnection
    assert(callback, "Callback must be provided.")
    -- Define a local buffer collection for this subscription.
    -- This is necessary because the same topic can be subscribed to multiple times.
    local buffers: {[string]: {FragmentBuffer}} = {}
    local streamConnection: StreamConnection
    local connection = MessagingService:SubscribeAsync(self.Topic, function(data: {Data: string, Sent: number})
        local message = CsrpMessage.fromString(data.Data)
        -- Check if the message should be processed by the current server.
        if not Router.IsCurrentServerRecipient(message) then
            return
        end
        -- If the message has an interaction ID, it can be handled as a fragment.
        if message.InteractionId then
            local bufferIsComplete = BufferFragment(streamConnection, message)
            if bufferIsComplete then
                local defragmentedMessage = Fragmenter.DefragmentMessages(buffers[message.InteractionId].Fragments)
                streamConnection.Buffers[message.InteractionId]:Dispose()
                streamConnection.Buffers[message.InteractionId] = nil
                callback(defragmentedMessage, data.Sent)
            end
        else
            callback(message, data.Sent)
        end
    end)
    streamConnection = StreamConnection.new(connection, buffers)
    return streamConnection
end

export type MessageStream = typeof(MessageStream.new())

return MessageStream
