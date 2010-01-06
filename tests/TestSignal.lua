require "lunit"
require "Signal"

module("Signal_testcase", lunit.testcase, package.seeall)

function setUp()
    signal = Signal:new()
    handler_counter = 0
end

function test_if_a_handler_function_is_connected_it_will_always_be_called()

    local handler = function () handler_counter = handler_counter + 1 end

    signal.connect(handler)
    assert_equal(0, handler_counter)
    signal.emit()
    assert_equal(1, handler_counter)
    signal.emit()
    assert_equal(2, handler_counter) 
end

lunit.main()
