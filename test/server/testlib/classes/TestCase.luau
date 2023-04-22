local TestCase = {}
TestCase.__index = TestCase

export type State = "Not run" | "Running" | "Passed" | "Failed" | "Skipped"

TestCase.new = function(name: string, fn: () -> ())
    local self = setmetatable({}, TestCase)
    self._name = name
    self._fn = fn
    self._before = {}
    self._after = {}
    self._state = "Not run"
    self._error = nil
    self._skip = false
    self._startTick = 0
    self._endTick = 0
    self._expectFail = false
    self._expectedError = nil
    return self
end

TestCase.Run = function(self: TestCase, env: {[string]: any?})
    if self._state ~= "Not run" then
        return
    end
    if self._skip then
        self._state = "Skipped"
        return
    end
    self._state = "Running"
    if #self._before > 0 then
        for _, fn in ipairs(self._before) do
            fn(env)
        end
    end
    self._startTick = tick()
    local success, err = pcall(self._fn, env)
    self._endTick = tick()

    -- If the test passed, and we didn't expect it to fail, report success
    if success and not self._expectFail then
        self._state = "Passed"

    -- If the test failed, and we didn't expect it to fail, report the error
    elseif success and self._expectFail then
        self._state = "Failed"
        self._error = "Expected test to fail, but it passed"
    
    -- If the test failed, but we expected it to fail, check if the error matches the expected error (if any)
    elseif not success and self._expectFail then
        -- If the error doesn't match the expected error, report the error
        if self._expectedError and not err:lower():find(self._expectedError:lower()) then
            self._state = "Failed"
            self._error = "Expected test to fail with error '" .. self._expectedError .. "', but it failed with error '" .. err .. "'"
        
        -- If the error matches the expected error, report success
        else
            self._error = err
            self._state = "Passed"
        end

    -- If the test failed, and we didn't expect it to fail, report the error
    else
        self._state = "Failed"
        self._error = if self._expectFail then "Expected test to fail, but it passed" else err
    end

    for _, fn in ipairs(self._after) do
        fn(env)
    end
end

TestCase.Before = function(self: TestCase, fn: () -> ())
    table.insert(self._before, fn)
    return self
end

TestCase.After = function(self: TestCase, fn: () -> ())
    table.insert(self._after, fn)
    return self
end

TestCase.Skip = function(self: TestCase)
    self._skip = true
    return self
end

TestCase.ExpectFail = function(self: TestCase, expectedError: string?)
    self._expectFail = true
    self._expectedError = expectedError
    return self
end

-- Return the test name and state. If the test failed, return the error message.
TestCase.GetReport = function(self: TestCase): string
    local state = self._state
    local name = self._name
    local emoji = if state == "Passed" then "✅" elseif state == "Failed" then "⛔" elseif state == "Skipped" then "⏭️" else "🕒"
    local report = `{emoji} {name} ({state})`
    if self._error then
        report ..= `: {self._error}`
    end
    return report
end

export type TestCase = typeof(TestCase.new(function() end))

return TestCase
