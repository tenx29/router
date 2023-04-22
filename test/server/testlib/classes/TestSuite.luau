local TestCase = require(script.Parent.TestCase)
type TestCase = TestCase.TestCase

export type State = TestCase.State

local TestSuite = {}
TestSuite.__index = TestSuite

TestSuite.new = function(name: string, tests: {TestCase | TestSuite})
    local self = setmetatable({}, TestSuite)
    self._name = name
    self._tests = tests
    self._state = "Not run"
    self._skip = false
    self._startTick = 0
    self._endTick = 0
    self._passedTests = 0
    self._failedTests = 0
    self._skippedTests = 0
    self._totalTests = 0
    self._after = {}
    return self
end

TestSuite.Run = function(self: TestSuite, env: {[string]: any?})
    if self._state ~= "Not run" then
        return
    end
    if self._skip then
        self._state = "Skipped"
    else
        self._state = "Running"
    end
    self._startTick = tick()
    for _, test in ipairs(self._tests) do
        if self._skip then
            test:Skip()
        end
        test:Run(env)
        if test._state == "Failed" then
            self._state = "Failed"
        end
    end
    self._endTick = tick()
    if self._state == "Running" then
        self._state = "Passed"
    end
    for _, fn in ipairs(self._after) do
        fn(env)
    end
end

TestSuite.BeforeEach = function(self: TestSuite, fn: () -> ())
    for _, test in ipairs(self._tests) do
        if test.Before then
            test:Before(fn)
        elseif test.BeforeEach then
            test:BeforeEach(fn)
        end
    end
    return self
end

TestSuite.AfterAll = function(self: TestSuite, fn: () -> ())
    table.insert(self._after, fn)
    return self
end

TestSuite.AfterEach = function(self: TestSuite, fn: () -> ())
    for _, test in ipairs(self._tests) do
        if test.AfterEach then
            test:AfterEach(fn)
        else
            test:After(fn)
        end
    end
    return self
end

TestSuite.Skip = function(self: TestSuite)
    self._skip = true
    return self
end

-- Return the test suite name and state. If the test suite failed, return the error message.
TestSuite.GetReport = function(self: TestSuite): string
    local state = self._state
    local name = self._name
    local emoji = if state == "Passed" then "✅" elseif state == "Failed" then "⛔" elseif state == "Skipped" then "⏭️" else "🕒"

    -- Format the run time
    local runTimeMs = string.format("%.2f", (self._endTick - self._startTick) * 1000)
    local runTimeS = string.format("%.2f", self._endTick - self._startTick)
    local runTime = if (self._endTick - self._startTick) > 10 then runTimeS.." s" else runTimeMs.." ms"

    -- Get all child test reports and indent them by one tab
    local caseReports = {}
    for _, test in ipairs(self._tests) do
        local testReport = test:GetReport()
        -- Count passed, failed, and skipped tests
        if test._tests then
            self._totalTests += test._totalTests
            self._passedTests += test._passedTests
            self._failedTests += test._failedTests
            self._skippedTests += test._skippedTests
        else
            self._totalTests += 1
            if test._state == "Passed" then
                self._passedTests += 1
            elseif test._state == "Failed" then
                self._failedTests += 1
            elseif test._state == "Skipped" then
                self._skippedTests += 1
            end
        end
        -- Split the test report into lines and indent each line
        local testReportLines = {}
        for line in testReport:gmatch("[^\r\n]+") do
            table.insert(testReportLines, "\t"..line)
        end

        -- Add the test report to the list of case reports
        table.insert(caseReports, table.concat(testReportLines, "\n"))
    end

    -- Format the report
    local passed = self._passedTests
    local failed = self._failedTests
    local skipped = self._skippedTests
    local total = self._totalTests
    local report = `{emoji} {name} ({passed} passed, {failed} failed, {skipped} skipped, {total} total, {runTime})`
    if state == "Failed" and self._error then
        report ..= `: {self._error}`
    end

    return report.."\n"..table.concat(caseReports, "\n")
end

export type TestSuite = typeof(TestSuite.new())

return TestSuite
