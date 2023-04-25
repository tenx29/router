local testlib = script.testlib
local Runner = require(testlib.Runner)

-- Only run unit tests in Roblox Studio
if game.JobId == "" then
    local unitTests = script.tests
    local report = Runner.Run(unitTests)
    print("Test results:\n"..report)
end

local e2e = script.e2e

-- Initialise responder for end-to-end tests
local initResponder = require(e2e.Responder)
initResponder()

-- Run E2E test listener in Roblox Studio and in the deployed game
local initE2E = require(e2e.Listener)
initE2E()
