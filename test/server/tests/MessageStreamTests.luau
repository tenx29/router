local mock = script.Parent.Parent.mock
local MessageStream = require(mock.MessageStream)

local router = script.Parent.Parent.Parent.Router
local CsrpMessageBuilder = require(router.CsrpMessageBuilder)

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

return TestSuite.new("MessageStream tests", {
    -- Messages are received
    TestCase.new("Messages are received", function()
        local count, counter = getCounter()
        local stream = MessageStream.new("test", 2)
        local connection = stream:Subscribe(counter)
        stream:Send(CsrpMessageBuilder.new():Build())
        connection:Disconnect()
        Assert.Equals(1, count())
    end),

    -- Message buffer tests
    TestSuite.new("Message buffer tests", {
        -- Connection is returned when subscribing
        TestCase.new("Connection is returned when subscribing", function()
            local _, counter = getCounter()
            local stream = MessageStream.new("test", 2)
            local connection = stream:Subscribe(counter)
            connection:Disconnect()
            Assert.IsType("table", connection)
            Assert.IsType("function", connection.Disconnect)
            Assert.IsType("table", connection.Buffers)
        end),

        -- Buffer is cleared after receiving single message
        TestCase.new("Buffer is cleared after receiving single message", function()
            local _, counter = getCounter()
            local stream = MessageStream.new("test", 2)
            local message = CsrpMessageBuilder.new():Build()
            local connection = stream:Subscribe(counter)
            stream:Send(message)
            Assert.Nil(connection.Buffers[message.InteractionId])
            connection:Disconnect()
        end),

        -- Fragmented messages are buffered until complete
        TestCase.new("Fragmented messages are buffered until complete", function()
            local count, counter = getCounter()
            local stream = MessageStream.new("test", 2)
            local message = CsrpMessageBuilder.new():Build()
            message.FragmentCount = 2
            message.Fragment = 1
            local connection = stream:Subscribe(counter)
            stream:Send(message)
            Assert.NotNil(connection.Buffers[message.InteractionId])
            Assert.Equals(1, #connection.Buffers[message.InteractionId].Fragments)
            local message2 = CsrpMessageBuilder.new():SetInteractionId(message.InteractionId):Build()
            message2.FragmentCount = 2
            message2.Fragment = 2
            stream:Send(message2)
            Assert.Nil(connection.Buffers[message.InteractionId])
            connection:Disconnect()
            Assert.Equals(1, count())
        end),

        -- Concurrent buffers are created for different interaction ids
        TestCase.new("Concurrent buffers are created for different interaction ids", function()
            local _, counter = getCounter()
            local stream = MessageStream.new("test", 2)
            local message = CsrpMessageBuilder.new():Build()
            message.FragmentCount = 2
            message.Fragment = 1
            local message2 = CsrpMessageBuilder.new():Build()
            message2.FragmentCount = 2
            message2.Fragment = 1
            local connection = stream:Subscribe(counter)
            local buffers = connection.Buffers
            stream:Send(message)
            stream:Send(message2)
            Assert.NotNil(buffers[message.InteractionId])
            Assert.NotNil(buffers[message2.InteractionId])

            -- Verify that the right messages are in the right buffers
            Assert.Equals(1, #buffers[message.InteractionId].Fragments)
            Assert.SerializedEquals(message, buffers[message.InteractionId].Fragments[1])
            Assert.Equals(1, #buffers[message2.InteractionId].Fragments)
            Assert.SerializedEquals(message2, buffers[message2.InteractionId].Fragments[1])

            -- Complete the buffers to free the memory
            local message3 = CsrpMessageBuilder.new():SetInteractionId(message.InteractionId):Build()
            message3.FragmentCount = 2
            message3.Fragment = 2
            local message4 = CsrpMessageBuilder.new():SetInteractionId(message2.InteractionId):Build()
            message4.FragmentCount = 2
            message4.Fragment = 2

            stream:Send(message3)
            stream:Send(message4)

            Assert.Nil(buffers[message.InteractionId])
            Assert.Nil(buffers[message2.InteractionId])

            -- Clean up
            connection:Disconnect()
        end),

        -- Multiple subscribers can buffer messages
        TestCase.new("Multiple subscribers can buffer messages", function()
            local count, counter = getCounter()
            local stream = MessageStream.new("test", 2)
            local message = CsrpMessageBuilder.new():Build()
            message.FragmentCount = 2
            message.Fragment = 1
            local connection = stream:Subscribe(counter)
            local connection2 = stream:Subscribe(counter)
            stream:Send(message)
            Assert.SerializedEquals(message, connection.Buffers[message.InteractionId].Fragments[1])
            Assert.SerializedEquals(message, connection2.Buffers[message.InteractionId].Fragments[1])
            local message2 = CsrpMessageBuilder.new():SetInteractionId(message.InteractionId):Build()
            message2.FragmentCount = 2
            message2.Fragment = 2
            stream:Send(message2)
            Assert.Nil(connection.Buffers[message.InteractionId])
            Assert.Nil(connection2.Buffers[message.InteractionId])
            Assert.Equals(2, count())
            -- Clean up
            connection:Disconnect()
            connection2:Disconnect()
        end),

        -- Messages are not buffered after disconnect
        TestCase.new("Messages are not buffered after disconnect", function()
            local _, counter = getCounter()
            local stream = MessageStream.new("test", 2)
            local message = CsrpMessageBuilder.new():Build()
            message.FragmentCount = 2
            message.Fragment = 1
            local connection = stream:Subscribe(counter)
            connection:Disconnect()
            stream:Send(message)
            Assert.Nil(connection.Buffers[message.InteractionId])
        end),

        -- Active buffers are disposed when disconnecting
        TestCase.new("Active buffers are disposed when disconnecting", function()
            local _, counter = getCounter()
            local stream = MessageStream.new("test", 2)
            local message = CsrpMessageBuilder.new():Build()
            message.FragmentCount = 2
            message.Fragment = 1
            local connection = stream:Subscribe(counter)
            stream:Send(message)
            Assert.NotNil(connection.Buffers[message.InteractionId])
            connection:Disconnect()
            Assert.Nil(connection.Buffers[message.InteractionId])
        end),

        TestCase.new("Time out event is fired", function()
            local count, counter = getCounter()
            local stream = MessageStream.new("test", 2)
            local message = CsrpMessageBuilder.new():Build()
            message.FragmentCount = 2
            message.Fragment = 1
            local connection = stream:Subscribe(function() end)
            stream:Send(message)
            connection.Buffers[message.InteractionId].TimedOut:Connect(counter)
            connection.Buffers[message.InteractionId].TimedOut:Wait()
            task.wait()
            Assert.Equals(1, count())
            connection:Disconnect()
        end),
    
        TestCase.new("Can't add to timed out buffer", function()
            local count, counter = getCounter()
            local stream = MessageStream.new("test", 2)
            local message = CsrpMessageBuilder.new():Build()
            message.FragmentCount = 2
            message.Fragment = 1
            local connection = stream:Subscribe(function() end)
            stream:Send(message)
            connection.Buffers[message.InteractionId].TimedOut:Connect(counter)
            connection.Buffers[message.InteractionId].TimedOut:Wait()
            task.wait()
            Assert.Equals(1, count())
            stream:Send(message)
        end):ExpectFail("Attempted to add fragment to timed out buffer"),
    }),

    TestSuite.new("Message routing tests", {
        TestCase.new("Broadcast is routed to all servers", function()
            local count, counter = getCounter()
            local stream = MessageStream.new("test", 2)
            local connection = stream:Subscribe(counter)
            local message = CsrpMessageBuilder.new():Build()
            stream:Send(message)
            Assert.Equals(1, count())
            connection:Disconnect()
        end),

        TestCase.new("localhost is routed to Roblox Studio", function()
            local count, counter = getCounter()
            local stream = MessageStream.new("test", 2)
            local connection = stream:Subscribe(counter)
            local message = CsrpMessageBuilder.new():AddRecipient("localhost"):Build()
            stream:Send(message)
            Assert.Equals(1, count())
            connection:Disconnect()
        end),

        TestCase.new("Address negation works", function()
            local count, counter = getCounter()
            local stream = MessageStream.new("test", 2)
            local connection = stream:Subscribe(counter)
            local message = CsrpMessageBuilder.new():AddRecipient("localhost"):AddRecipient("-localhost"):Build()
            stream:Send(message)
            Assert.Equals(0, count())
            connection:Disconnect()
        end),

        TestCase.new("Messages for other servers are ignored", function()
            local count, counter = getCounter()
            local stream = MessageStream.new("test", 2)
            local connection = stream:Subscribe(counter)
            local message = CsrpMessageBuilder.new():AddRecipient("other"):Build()
            stream:Send(message)
            Assert.Equals(0, count())
            connection:Disconnect()
        end),

        TestCase.new("Global negation is not processed", function()
            local count, counter = getCounter()
            local stream = MessageStream.new("test", 2)
            local connection = stream:Subscribe(counter)
            local message = CsrpMessageBuilder.new():AddRecipient("-"):Build()
            stream:Send(message)
            Assert.Equals(0, count())
            connection:Disconnect()
        end),

        TestCase.new("'All servers except' expression is processed correctly", function()
            local count, counter = getCounter()
            local stream = MessageStream.new("test", 2)
            local connection = stream:Subscribe(counter)
            local message = CsrpMessageBuilder.new():AddRecipient(""):AddRecipient("-localhost"):Build()
            stream:Send(message)
            Assert.Equals(0, count())
            connection:Disconnect()
        end)
    })
})