-- Quick and dirty mock of MessagingService for testing purposes
local RBXScriptConnection = require(script.Parent.RBXScriptConnection)

local MessagingService = {}
MessagingService.__index = MessagingService

local topics: {[string]: {RBXScriptConnection.RBXScriptConnection}} = {}

MessagingService.new = function()
    return setmetatable({}, MessagingService)
end

MessagingService.PublishAsync = function(_self, topic, payload)
    if not topics[topic] then
        topics[topic] = {}
    end
    for _, connection in ipairs(topics[topic]) do
        connection({Data = payload, Sent = os.time()})
    end
end

MessagingService.SubscribeAsync = function(_self, topic, callback)
    if not topics[topic] then
        topics[topic] = {}
    end
    local connection = RBXScriptConnection.new(callback)
    table.insert(topics[topic], connection)
    return connection
end

return MessagingService.new()
