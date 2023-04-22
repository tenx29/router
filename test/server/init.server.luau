local testlib = script.testlib
local Runner = require(testlib.Runner)

-- Only run unit tests in Roblox Studio
if game.JobId == "" then
    local unitTests = script.tests
    local report = Runner.Run(unitTests)
    print("Test results:\n"..report)
end

local integrationTests = script.integration

-- Initialise responder for integration tests
local initResponder = require(integrationTests.Responder)
initResponder()

-- Run integration tests in Roblox Studio and in the deployed game
local initIntegration = require(integrationTests.Listener)
initIntegration()
