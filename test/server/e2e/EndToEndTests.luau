local router = script.Parent.Parent.Parent.Router
local CsrpMessageBuilder = require(router.CsrpMessageBuilder)
local MessageStream = require(router.MessageStream)

local testlib = script.Parent.Parent.testlib
local testClasses = testlib.classes
local TestSuite = require(testClasses.TestSuite)
local TestCase = require(testClasses.TestCase)
local Assert = require(testlib.Assert)

local stream = MessageStream.new()
local connection

return TestSuite.new("Router E2E tests", {
    TestCase.new("Responses are received", function(env)
        local body = env.payload
        local message = CsrpMessageBuilder.new()
            :AddRecipient("")
            :ExcludeRecipient(game.JobId)
            :SetBody(body)
            :Build()
        local response
        local function setResponse(r)
            response = r
        end
        connection = stream:Subscribe(setResponse)
        stream:Send(message)
        task.wait(2)
        Assert.NotNil(response)
    end),

    TestCase.new("Response has correct body", function(env)
        local body = env.payload
        local message = CsrpMessageBuilder.new()
            :AddRecipient("")
            :ExcludeRecipient(game.JobId)
            :SetBody(body)
            :Build()
        local response
        local function setResponse(r)
            response = r
        end
        connection = stream:Subscribe(setResponse)
        stream:Send(message)
        task.wait(2)
        Assert.Equals(body..".response", response.Body)
    end),

    TestCase.new("Response options are correct", function(env)
        local body = env.payload
        local message = CsrpMessageBuilder.new()
            :AddRecipient("")
            :ExcludeRecipient(game.JobId)
            :SetBody(body)
            :Build()
        local response
        local function setResponse(r)
            response = r
        end
        connection = stream:Subscribe(setResponse)
        stream:Send(message)
        task.wait(2)
        Assert.Equals("response=true", response.Options)
    end),

    TestCase.new("Response has correct sender", function(env)
        local body = env.payload
        local message = CsrpMessageBuilder.new()
            :AddRecipient("")
            :ExcludeRecipient(game.JobId)
            :SetBody(body)
            :Build()
        local response
        local function setResponse(r)
            response = r
        end
        connection = stream:Subscribe(setResponse)
        stream:Send(message)
        task.wait(2)
        Assert.NotEqual(game.JobId, response.Sender)
    end),

    TestCase.new("Responses to a different stream are ignored", function(env)
        local body = env.payload
        local message = CsrpMessageBuilder.new()
            :AddRecipient("")
            :ExcludeRecipient(game.JobId)
            :SetBody(body)
            :Build()
        local response
        local function setResponse(r)
            response = r
        end
        connection = stream:Subscribe(setResponse)
        local otherStream = MessageStream.new("another stream")
        otherStream:Send(message)
        task.wait(2)
        Assert.Nil(response)
    end)
}):AfterEach(function()
    if connection then
        connection:Disconnect()
        print("Disconnected from previous test")
    end
    task.wait()
end)
