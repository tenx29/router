--!strict
--[[
    CSRP Message Stream

    Class for handling CSRP message streams.
]]
local MessagingService = game:GetService("MessagingService")

local RouterLib = script.Parent
local CsrpMessage = require(RouterLib.CsrpMessage)
local CsrpMessageBuilder = require(RouterLib.CsrpMessageBuilder)
local CsrpMessageFragment = require(RouterLib.CsrpMessageFragment)
export type CsrpMessage = CsrpMessage.CsrpMessage
export type CsrpMessageBuilder = CsrpMessageBuilder.CsrpMessageBuilder
export type CsrpMessageFragment = CsrpMessageFragment.CsrpMessageFragment

local FragmentBuffer = require(RouterLib.FragmentBuffer)
local StreamConnection = require(RouterLib.StreamConnection)
export type FragmentBuffer = FragmentBuffer.FragmentBuffer
export type StreamConnection = StreamConnection.StreamConnection

local Fragmenter = require(RouterLib.Fragmenter)
local RoutingUtil = require(RouterLib.RoutingUtil)

local MessageStream = {}
MessageStream.__index = MessageStream

local DEFAULT_MESSAGE_STREAM_TOPIC = "CSRP_GLOBAL"

MessageStream.new = function(topic: string?, bufferTimeout: number?): MessageStream
    local self = setmetatable({}, MessageStream)
    self.Topic = topic or DEFAULT_MESSAGE_STREAM_TOPIC
    self.BufferTimeout = bufferTimeout or 10
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
local function BufferFragment(connection: StreamConnection, fragment: CsrpMessageFragment, bufferTimeout: number?): boolean
    local interactionId: string = fragment.InteractionId or ""
    if not connection.Buffers[interactionId] then
        local buffer = FragmentBuffer.new(bufferTimeout)
        connection.Buffers[interactionId] = buffer::FragmentBuffer
        buffer.TimedOut:Connect(function(err: string?)
            buffer:Dispose()
            error(err or "Fragment buffer timed out.")
        end)
    end
    connection.Buffers[interactionId]:Add(fragment)
    local buffer = connection.Buffers[interactionId]
    return (buffer.IsComplete::(FragmentBuffer) -> boolean)(buffer)
end

-- Subscribes to the message stream and returns a connection.
MessageStream.Subscribe = function(self: MessageStream, callback: (CsrpMessage, number) -> ()): StreamConnection
    assert(callback, "Callback must be provided.")
    -- Define a local buffer collection for this subscription.
    -- This is necessary because the same topic can be subscribed to multiple times.
    local buffers: {[string]: FragmentBuffer} = {}
    local streamConnection: StreamConnection
    local connection = MessagingService:SubscribeAsync(self.Topic, function(data: {Data: string, Sent: number})
        local message = CsrpMessageFragment.fromString(data.Data)
        -- If the message has an interaction ID, it can be handled as a fragment.
        if message.InteractionId then
            local bufferIsComplete = BufferFragment(streamConnection, message, self.BufferTimeout)
            if bufferIsComplete then
                local defragmentedMessage = Fragmenter.DefragmentMessages(buffers[message.InteractionId].Fragments)
                streamConnection.Buffers[message.InteractionId]:Dispose()
                streamConnection.Buffers[message.InteractionId] = nil
                -- Check if the message should be processed by the current server.
                if not RoutingUtil.IsCurrentServerRecipient(defragmentedMessage) then
                    return
                end
                callback(defragmentedMessage, data.Sent)
            end
        else
            -- Defragment the message and pass it to the callback.
            local defragmentedMessage = Fragmenter.DefragmentMessages({message})
            -- Check if the message should be processed by the current server.
            if not RoutingUtil.IsCurrentServerRecipient(defragmentedMessage) then
                return
            end
            callback(defragmentedMessage, data.Sent)
        end
    end)
    streamConnection = StreamConnection.new(connection, buffers)
    return streamConnection
end

export type MessageStream = typeof(MessageStream.new())

return MessageStream
