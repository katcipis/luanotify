--[[
   Copyright (C) 2010 Digitro Corporation <www.digitro.com.br>
 
   @author Paulo Pizarro  <paulo.pizarro@gmail.com>
   @author Tiago Katcipis <tiagokatcipis@gmail.com>
 
   This file is part of LuaNotify.
 
   LuaNotify is free software: you can redistribute it and/or modify
   it under the terms of the GNU Lesser General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
 
   LuaNotify is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU Lesser General Public License for more details.
 
   You should have received a copy of the GNU Lesser General Public License
   along with Luasofia.  If not, see <http://www.gnu.org/licenses/>.
--]]


require "lunit"
require "Signal"

module("Signal_testcase", lunit.testcase, package.seeall)

function setUp()
    signal = Signal:new()
    handler_counter = 0
end

function tearDown()
    signal = nil
end


local function handler1 ()
          assert_equal(0, handler_counter)
          handler_counter = handler_counter + 1
      end

local function handler2 ()
          assert_equal(1, handler_counter)
          handler_counter = handler_counter + 1
      end

local function handler3 ()
          assert_equal(2, handler_counter)
          handler_counter = handler_counter + 1
      end


function test_if_a_handler_function_is_connected_it_will_always_be_called_when_a_emission_occurs()

    local handler = function () handler_counter = handler_counter + 1 end

    signal:connect(handler)
    assert_equal(0, handler_counter)
    signal:emit()
    assert_equal(1, handler_counter)
    signal:emit()
    assert_equal(2, handler_counter) 
end

function test_if_there_is_no_handler_connected_emission_does_nothing()
    assert_equal(0, handler_counter)
    signal:emit()
    assert_equal(0, handler_counter)
end

function test_handlers_are_called_on_the_order_they_are_inserted()
    handler1 = function ()
                   assert_equal(0, handler_counter)
                   handler_counter = handler_counter + 1
               end

    handler2 = function ()
                   assert_equal(1, handler_counter)
                   handler_counter = handler_counter + 1
               end

    handler3 = function ()
                   assert_equal(2, handler_counter)
                   handler_counter = handler_counter + 1
               end

     signal:connect(handler1)
     signal:connect(handler2)
     signal:connect(handler3)
     signal:emit()
end

function test_handlers_receive_all_the_data_that_is_passed_on_emission()
    handler  = function (arg)
                   assert_equal("pineapple", arg)
               end

    signal:connect(handler)
    signal:emit("pineapple")

end


function test_handlers_receive_all_the_data_that_is_passed_on_emission_on_the_order_it_was_on_emission_call()

    handler = function (arg1,arg2,arg3)
                   assert_equal(1, arg1)
                   assert_equal(2, arg2)
                   assert_equal("pineapple", arg3)
               end

    signal:connect(handler)
    signal:emit(1,2,"pineapple")

end

function test_what_happens_if_we_connect_the_same_handler_multiple_times()
    --TODO
end

function test_the_same_handler_can_be_connected_on_multiple_signals()
    local handler = function () handler_counter = handler_counter + 1 end
    local signal2 = Signal:new()
    
    signal:connect(handler)
    signal2:connect(handler)

    assert_equal(0, handler_counter)
    signal:emit()
    assert_equal(1, handler_counter)
    signal2:emit()
    assert_equal(2, handler_counter)
end

function test_if_a_handler_is_disconnected_the_order_of_the_remaining_handlers_wont_change()
    handler1 = function ()
                  assert_equal(0, handler_counter)
                  handler_counter = handler_counter + 1
               end

    handler2 = function ()
                  assert_equal(1, handler_counter)
                  handler_counter = handler_counter + 1
               end

    handler3 = function (offset)
                  local offset = offset or 0
                  assert_equal(2 - offset, handler_counter)
                  handler_counter = handler_counter + 1
               end

    signal:connect(handler1)
    signal:connect(handler2)
    signal:connect(handler3)
    signal:emit()

    signal:disconnect(handler2)
    handler_counter = 0
    signal:emit(1)
end

function test_if_a_handler_is_disconnected_it_will_not_be_called_anymore()
    local handler = function () handler_counter = handler_counter + 1 end

    signal:connect(handler)
    assert_equal(0, handler_counter)
    signal:emit()
    assert_equal(1, handler_counter)
    signal:disconnect(handler)
    signal:emit()
    assert_equal(1, handler_counter)
end

function test_if_a_handler_got_blocked_it_wont_be_called_on_emission()
    local handler = function () handler_counter = handler_counter + 1 end

    signal:connect(handler)
    assert_equal(0, handler_counter)
    signal:emit()
    assert_equal(1, handler_counter)
    signal:block(handler)
    signal:emit()
    assert_equal(1, handler_counter)
    signal:emit()
    assert_equal(1, handler_counter)
end

function test_a_blocked_handler_can_be_unblocked()
    local handler = function () handler_counter = handler_counter + 1 end

    signal:connect(handler)
    assert_equal(0, handler_counter)
    signal:emit()
    assert_equal(1, handler_counter)
    signal:block(handler)
    signal:emit()
    assert_equal(1, handler_counter)
    signal:unblock(handler)
    signal:emit()
    assert_equal(2, handler_counter)
end

function test_a_unblocked_handler_will_be_called_on_its_original_position()
    handler1 = function ()
                  assert_equal(0, handler_counter)
                  handler_counter = handler_counter + 1
               end

    handler2 = function ()
                  assert_equal(1, handler_counter)
                  handler_counter = handler_counter + 1
               end

    handler3 = function (offset)
                  local offset = offset or 0
                  assert_equal(2 - offset, handler_counter)
                  handler_counter = handler_counter + 1
               end

    signal:connect(handler1)
    signal:connect(handler2)
    signal:connect(handler3)
    signal:block(handler2)
    signal:emit(1)
 
    handler_counter = 0
    signal:unblock(handler2)
    signal:emit()   

end

function test_a_handler_must_be_unblocked_the_same_times_it_has_been_blocked()
    local handler = function () handler_counter = handler_counter + 1 end

    signal:connect(handler)
    signal:block(handler)
    signal:block(handler)
    signal:block(handler)

    signal:emit()
    assert_equal(0, handler_counter)
    
    signal:unblock(handler)
    signal:emit()
    assert_equal(0, handler_counter)

    signal:unblock(handler)
    signal:emit()
    assert_equal(0, handler_counter)

    signal:unblock(handler)
    signal:emit()
    assert_equal(1, handler_counter)
end


lunit.main()
