local HttpService = game:GetService("HttpService")

local router = script.Parent.Parent.Parent.Router
local CsrpMessageBuilder = require(router.CsrpMessageBuilder)
local Fragmenter = require(router.Fragmenter)
type Fragmenter = Fragmenter.Fragmenter

local testlib = script.Parent.Parent.testlib
local testClasses = testlib.classes
local TestSuite = require(testClasses.TestSuite)
local TestCase = require(testClasses.TestCase)
local Assert = require(testlib.Assert)

local longBody = string.rep("a", 500)..string.rep("b", 500)

local longerBody = HttpService:GenerateGUID(false):rep(50)
    ..HttpService:GenerateGUID(false):rep(50)
    ..HttpService:GenerateGUID(false):rep(50)
    ..HttpService:GenerateGUID(false):rep(50)
    ..HttpService:GenerateGUID(false):rep(50)

return TestSuite.new("Fragmenter tests", {
    TestCase.new("Fragment size is correct", function()
        local message = CsrpMessageBuilder.new():SetBody(longBody):Build()
        local fragments = Fragmenter.FragmentMessage(message)
        Assert.Equals(2, #fragments)
        Assert.True(#tostring(fragments[1]) <= 1000)
    end),

    TestCase.new("Fragments are reassembled correctly", function()
        local message = CsrpMessageBuilder.new():SetBody(longerBody):Build()
        local fragments = Fragmenter.FragmentMessage(message)
        local reassembled = Fragmenter.DefragmentMessages(fragments)
        Assert.SerializedEquals(message, reassembled)
    end),

    TestCase.new("Fragment headers are correct", function()
        local message = CsrpMessageBuilder.new()
            :AddRecipient(HttpService:GenerateGUID(false))
            :AddRecipient(HttpService:GenerateGUID(false))
            :SetSender("localhost")
            :SetBody(longerBody)
            :SetOption("testOption", "testValue")
            :Build()
        local fragments = Fragmenter.FragmentMessage(message)
        local reassembled = Fragmenter.DefragmentMessages(fragments)
        Assert.SerializedEquals(message, reassembled)
        Assert.Equals(message.Recipients, reassembled.Recipients)
        Assert.Equals(message.Sender, reassembled.Sender)
        Assert.Equals(message.Options, reassembled.Options)
        Assert.Nil(reassembled.Fragment)
        Assert.Nil(reassembled.FragmentCount)
    end),
})