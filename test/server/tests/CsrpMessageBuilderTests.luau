local router = script.Parent.Parent.Parent.Router
local CsrpMessageBuilder = require(router.CsrpMessageBuilder)

local testlib = script.Parent.Parent.testlib
local testClasses = testlib.classes
local TestSuite = require(testClasses.TestSuite)
local TestCase = require(testClasses.TestCase)
local Assert = require(testlib.Assert)

return TestSuite.new("CSRP Message Builder Tests", {
    TestCase.new("Build() returns a table", function()
        local message = CsrpMessageBuilder.new():Build()
        Assert.Equals("table", typeof(message))
    end),

    TestCase.new("SetSender() sets the Sender field", function()
        local message = CsrpMessageBuilder.new():SetSender("test"):Build()
        Assert.Equals("test", message.Sender)
    end),

    TestCase.new("Sender with ; is rejected", function()
        CsrpMessageBuilder.new():SetSender("invalid;sender"):Build()
    end):ExpectFail("illegal character"),

    TestCase.new("AddRecipient() adds a recipient", function()
        local message = CsrpMessageBuilder.new():AddRecipient("test"):Build()
        Assert.Equals("test", message.Recipients)
    end),

    TestCase.new("ExcludeRecipient() adds a recipient prefixed with -", function()
        local message = CsrpMessageBuilder.new():ExcludeRecipient("test"):Build()
        Assert.Equals("-test", message.Recipients)
    end),

    TestCase.new("Multiple recipients are comma-separated", function()
        local message = CsrpMessageBuilder.new():AddRecipient("test"):AddRecipient("test2"):Build()
        Assert.Equals("test,test2", message.Recipients)
    end),

    TestCase.new("Recipients with ; are rejected", function()
        CsrpMessageBuilder.new():AddRecipient("invalid;recipient"):Build()
    end):ExpectFail("illegal character"),

    TestCase.new("SetRecipients() sets the Recipients field", function()
        local recipients = {"test", "test2"}
        local message = CsrpMessageBuilder.new():SetRecipients(recipients):Build()
        Assert.Equals("test,test2", message.Recipients)
    end),

    TestCase.new("SetRecipients() fails if any recipient contains ;", function()
        CsrpMessageBuilder.new():SetRecipients({"test", "invalid;recipient"}):Build()
    end):ExpectFail("illegal character"),

    TestCase.new("SetBody() sets the Body field", function()
        local message = CsrpMessageBuilder.new():SetBody("test"):Build()
        Assert.Equals("test", message.Body)
    end),

    TestCase.new("SetOption() sets an option", function()
        local message = CsrpMessageBuilder.new():SetOption("key", "value"):Build()
        Assert.Equals("key=value", message.Options)
    end),

    TestCase.new("Calling SetOption() twice with the same key overwrites the value", function()
        local message = CsrpMessageBuilder.new():SetOption("key", "value"):SetOption("key", "value2"):Build()
        Assert.Equals("key=value2", message.Options)
    end),

    TestSuite.new("SetOption() fails if", {
        TestCase.new("the key is nil", function()
            CsrpMessageBuilder.new():SetOption(nil, "value"):Build()
        end):ExpectFail(),

        TestCase.new("key contains ;", function()
            CsrpMessageBuilder.new():SetOption("invalid;key", "value"):Build()
        end):ExpectFail("illegal character"),

        TestCase.new("key contains =", function()
            CsrpMessageBuilder.new():SetOption("invalid=key", "value"):Build()
        end):ExpectFail("illegal character"),

        TestCase.new("key contains ,", function()
            CsrpMessageBuilder.new():SetOption("invalid,key", "value"):Build()
        end):ExpectFail("illegal character"),

        TestCase.new("value contains ;", function()
            CsrpMessageBuilder.new():SetOption("key", "invalid;value"):Build()
        end):ExpectFail("illegal character"),

        TestCase.new("value contains =", function()
            CsrpMessageBuilder.new():SetOption("key", "invalid=value"):Build()
        end):ExpectFail("illegal character"),

        TestCase.new("value contains ,", function()
            CsrpMessageBuilder.new():SetOption("key", "invalid,value"):Build()
        end):ExpectFail("illegal character"),
    }),

    TestCase.new("InteractionId has a GUID as a default value", function()
        local message = CsrpMessageBuilder.new():Build()
        Assert.Equals(36, #message.InteractionId)
    end),

    TestCase.new("SetInteractionId() fails if the value contains ;", function()
        CsrpMessageBuilder.new():SetInteractionId("invalid;id"):Build()
    end):ExpectFail("illegal character"),

    TestCase.new("SetInteractionId() sets the InteractionId field", function()
        local message = CsrpMessageBuilder.new():SetInteractionId("test"):Build()
        Assert.Equals("test", message.InteractionId)
    end),
})