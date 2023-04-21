local Assert = {}

Assert.Equals = function(expected: any?, actual: any?, message: string?)
    if expected ~= actual then
        error(message or `Expected {expected} (type {typeof(expected)}) but got {actual} (type {typeof(actual)})`)
    end
end

Assert.NotEqual = function(expected: any?, actual: any?, message: string?)
    if expected == actual then
        error(message or `Expected {expected} (type {typeof(expected)}) to not equal {actual} (type {typeof(actual)})`)
    end
end

Assert.True = function(value: any?, message: string?)
    assert(value == true, message or "Expected value to be true but got "..tostring(value))
end

Assert.False = function(value: any?, message: string?)
    assert(value == false, message or "Expected value to be false but got "..tostring(value))
end

Assert.SerializedEquals = function(expected: any?, actual: any?, message: string?)
    assert(tostring(expected) == tostring(actual), message or `Expected {expected} but got {actual}`)
end

Assert.SerializedNotEqual = function(expected: any?, actual: any?, message: string?)
    assert(tostring(expected) ~= tostring(actual), message or `Expected {expected} to not equal {actual}`)
end

Assert.IsType = function(expectedType: string, value: any?, message: string?)
    assert(typeof(value) == expectedType, message or "Expected "..tostring(value).." to be a "..expectedType)
end

Assert.Nil = function(value: any?, message: string?)
    assert(value == nil, message or "Expected value to be nil but got "..tostring(value))
end

Assert.NotNil = function(value: any?, message: string?)
    assert(value ~= nil, message or "Expected value to not be nil but got nil")
end

Assert.Length = function(expectedLength: number, actual: any, message: string?)
    assert(#actual == expectedLength, message or "Expected length of "..tostring(actual).." to be "..expectedLength.." but got "..#actual)
end

Assert.Table = {}

Assert.Table.Equals = function(expected: {[any]: any}, actual: {[any]: any}, recursive: boolean?, message: string?)
    for key, value in pairs(expected) do
        if recursive and typeof(value) == "table" then
            Assert.TableEqual(value, actual[key], recursive, message)
        else
            Assert.Equals(value, actual[key], message)
        end
    end
end

Assert.Table.NotEqual = function(expected: {[any]: any}, actual: {[any]: any}, recursive: boolean?, message: string?)
    local exactMatch = true
    for key, value in pairs(expected) do
        if recursive and typeof(value) == "table" then
            Assert.TableNotEqual(value, actual[key], recursive, message)
        elseif value ~= actual[key] then
            exactMatch = false
        end
    end
    if exactMatch then
        error(message or "Expected "..tostring(expected).." to not equal "..tostring(actual))
    end
end

Assert.String = {}

Assert.String.StartsWith = function(expected: string, actual: string, message: string?)
    assert(actual:sub(1, #expected) == expected, message or "Expected "..tostring(actual).." to start with "..tostring(expected))
end

Assert.String.EndsWith = function(expected: string, actual: string, message: string?)
    assert(actual:sub(-#expected) == expected, message or "Expected "..tostring(actual).." to end with "..tostring(expected))
end

Assert.String.Contains = function(expected: string, actual: string, message: string?)
    assert(actual:find(expected), message or "Expected "..tostring(actual).." to contain "..tostring(expected))
end

return Assert