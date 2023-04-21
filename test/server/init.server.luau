local testlib = script.testlib
local Runner = require(testlib.Runner)

local tests = script.tests

local report = Runner.Run(tests)
print("Test results:\n"..report)
