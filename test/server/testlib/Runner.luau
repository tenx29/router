local classes = script.Parent.classes
local TestSuite = require(classes.TestSuite)
type TestSuite = TestSuite.TestSuite

local Runner = {}

-- Discover all tests in the tests container and return them as a TestSuite
Runner.Discover = function(container: Instance): TestSuite
    print("Discovering tests...")
    local testObjects = {}
    for _, object in container:GetChildren() do
        if object:IsA("ModuleScript") and object.Name:lower():find("test") and object.Name:lower():sub(-5) ~= ".skip" then
            local testSuite = require(object)
            table.insert(testObjects, testSuite)
        end
    end
    return TestSuite.new("All tests", testObjects)
end

-- Run all tests in the tests container and get a report of the results
Runner.Run = function(container: Instance, env: {[string]: any?}): string
    local rootSuite = Runner.Discover(container)
    rootSuite:Reset()
    print("Running tests...")
    rootSuite:Run(env)
    print("Generating report...")
    return rootSuite:GetReport()
end

return Runner
