local mock = script.Parent.Parent.mock
local MessagingService = require(mock.MessagingService)

local testlib = script.Parent.Parent.testlib
local testClasses = testlib.classes
local TestSuite = require(testClasses.TestSuite)
local TestCase = require(testClasses.TestCase)
local Assert = require(testlib.Assert)

-- Helper function to create a counter and increment function
-- First return value is a function that returns the current count
-- Second return value is a function that increments the count
local function getCounter(): (() -> number, () -> ())
    local count = 0
    local getCount = function()
        return count
    end
    local increment = function()
        count += 1
    end
    return getCount, increment
end

return TestSuite.new("Mock MessagingService tests", {
    -- Disconnect function exists
    TestCase.new("Subscription has Disconnect function", function()
        local _, counter = getCounter()
        local connection = MessagingService:SubscribeAsync("test", counter)
        Assert.NotNil(connection.Disconnect)
    end),
    
    -- PublishAsync calls callback
    TestCase.new("PublishAsync calls callback", function()
        local count, counter = getCounter()
        local connection = MessagingService:SubscribeAsync("test", counter)
        MessagingService:PublishAsync("test", "test")
        Assert.Equals(1, count())
        connection:Disconnect()
    end),

    -- Callback isn't called when topic doesn't match
    TestCase.new("Callback isn't called when topic doesn't match", function()
        local count, counter = getCounter()
        local connection = MessagingService:SubscribeAsync("test", counter)
        MessagingService:PublishAsync("test2", "test")
        Assert.Equals(0, count())
        connection:Disconnect()
    end),

    -- Callback isn't called after disconnect
    TestCase.new("Callback isn't called after disconnect", function()
        local count, counter = getCounter()
        local connection = MessagingService:SubscribeAsync("test", counter)
        MessagingService:PublishAsync("test", "test")
        connection:Disconnect()
        MessagingService:PublishAsync("test", "test")
        Assert.Equals(1, count())
    end),

    -- Callback receives correct payload
    TestCase.new("Callback receives correct payload", function()
        local expected = {
            Data = "test",
            Sent = os.time(),
        }
        local connection = MessagingService:SubscribeAsync("test", function(data)
            Assert.Table.Equals(expected, data)
        end)
        MessagingService:PublishAsync("test", expected.Data)
        connection:Disconnect()
    end),

    -- Callback receives correct payload when multiple subscribers
    TestCase.new("Callback receives correct payload when multiple subscribers", function()
        local expected = {
            Data = "test",
            Sent = os.time(),
        }
        local count, counter = getCounter()
        local connection1 = MessagingService:SubscribeAsync("test", counter)
        local connection2 = MessagingService:SubscribeAsync("test", function(data)
            Assert.Table.Equals(expected, data)
        end)
        MessagingService:PublishAsync("test", expected.Data)
        Assert.Equals(1, count())
        connection1:Disconnect()
        connection2:Disconnect()
    end),

    -- Multiple topics can be subscribed to
    TestCase.new("Multiple topics can be subscribed to", function()
        local count, counter = getCounter()
        local connection1 = MessagingService:SubscribeAsync("test", counter)
        local connection2 = MessagingService:SubscribeAsync("test2", counter)
        MessagingService:PublishAsync("test", "test")
        MessagingService:PublishAsync("test2", "test")
        Assert.Equals(2, count())
        connection1:Disconnect()
        connection2:Disconnect()
    end),

    -- Disconnecting callback from one topic doesn't disconnect reused callback from another topic
    TestCase.new("Disconnecting callback from one topic doesn't disconnect reused callback from another topic", function()
        local count, counter = getCounter()
        local connection1 = MessagingService:SubscribeAsync("test", counter)
        local connection2 = MessagingService:SubscribeAsync("test2", counter)
        MessagingService:PublishAsync("test", "test")
        MessagingService:PublishAsync("test2", "test")
        Assert.Equals(2, count())
        connection1:Disconnect()
        MessagingService:PublishAsync("test", "test")
        Assert.Equals(2, count())
        MessagingService:PublishAsync("test2", "test")
        Assert.Equals(3, count())
        connection2:Disconnect()
    end),
})