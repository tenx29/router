local router = script.Parent.Parent.Parent.Router
local CsrpMessage = require(router.CsrpMessage)

local testlib = script.Parent.Parent.testlib
local testClasses = testlib.classes
local TestSuite = require(testClasses.TestSuite)
local TestCase = require(testClasses.TestCase)
local Assert = require(testlib.Assert)

return TestSuite.new("CSRP Message Tests", {
    TestCase.new("Constructor returns a valid CsrpMessage", function()
        local message = CsrpMessage.new(nil, nil, "")
        Assert.Equals("table", typeof(message))
        Assert.NotNil(message.Sender)
    end),

    TestCase.new("Constructor fails if sender contains ;", function()
        CsrpMessage.new("invalid;sender", nil, "")
    end):ExpectFail("illegal character"),

    TestCase.new("Constructor fails if recipients table contains ;", function()
        CsrpMessage.new(nil, {"invalid;recipient"}, "")
    end):ExpectFail("illegal character"),

    TestCase.new("Constructor fails if recipients string contains ;", function()
        CsrpMessage.new(nil, "invalid;recipient", "")
    end):ExpectFail("illegal character"),

    TestCase.new("Constructor fails if interaction ID contains ;", function()
        CsrpMessage.new(nil, nil, "invalid;interaction")
    end):ExpectFail("illegal character"),

    TestCase.new("Constructor fails if any key in options contains ;", function()
        CsrpMessage.new(nil, nil, "", {["invalid;key"] = "value"})
    end):ExpectFail("illegal character"),

    TestCase.new("Constructor fails if any value in options contains ;", function()
        CsrpMessage.new(nil, nil, "", {invalid = "invalid;value"})
    end):ExpectFail("illegal character"),

    TestCase.new("Options table is serialized correctly", function()
        local message = CsrpMessage.new(nil, nil, "", {key1 = "value1", key2 = "value2"})
        Assert.Equals("key1=value1,key2=value2", message.Options)
    end),

    TestCase.new("CSRP message is serialized correctly", function()
        local message = CsrpMessage.new("sender", {"recipient1", "recipient2"}, "interaction", {key1 = "value1", key2 = "value2"}, "body")
        Assert.Equals("interaction;sender;recipient1,recipient2;key1=value1,key2=value2;body", tostring(message))
    end),

    TestCase.new("CSRP message is serialized correctly if body contains ;", function()
        local message = CsrpMessage.new("sender", {"recipient1", "recipient2"}, "interaction", {key1 = "value1", key2 = "value2"}, "body that contains a ; character")
        Assert.Equals("interaction;sender;recipient1,recipient2;key1=value1,key2=value2;body that contains a ; character", tostring(message))
    end),

    TestCase.new("CSRP message is serialized correctly with missing sections", function()
        local message = CsrpMessage.new(nil, nil, "interaction", nil, "body that contains a ; character")
        Assert.Equals("interaction;;;;body that contains a ; character", tostring(message))
    end),

    TestCase.new("CSRP message is parsed correctly", function()
        local message = CsrpMessage.fromString("interaction;sender;recipient1,recipient2;key1=value1,key2=value2;body")
        Assert.Equals("sender", message.Sender)
        Assert.Equals("recipient1,recipient2", message.Recipients)
        Assert.Equals("interaction", message.InteractionId)
        Assert.Equals("key1=value1,key2=value2", message.Options)
        Assert.Equals("body", message.Body)
    end),

    TestCase.new("CSRP message is parsed correctly if body contains ;", function()
        local message = CsrpMessage.fromString("interaction;sender;recipient1,recipient2;key1=value1,key2=value2;body that contains a ; character")
        Assert.Equals("sender", message.Sender)
        Assert.Equals("recipient1,recipient2", message.Recipients)
        Assert.Equals("interaction", message.InteractionId)
        Assert.Equals("key1=value1,key2=value2", message.Options)
        Assert.Equals("body that contains a ; character", message.Body)
    end),

    TestCase.new("CSRP message is parsed correctly with missing sections", function()
        local message = CsrpMessage.fromString("interaction;;;;body that contains a ; character")
        Assert.Equals("", message.Sender)
        Assert.Equals("", message.Recipients)
        Assert.Equals("interaction", message.InteractionId)
        Assert.Equals("", message.Options)
        Assert.Equals("body that contains a ; character", message.Body)
    end),

    TestCase.new("Parsing an invalid message fails", function()
        CsrpMessage.fromString("invalid;message")
    end):ExpectFail("sections missing"),
})