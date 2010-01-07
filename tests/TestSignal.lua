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


function test_if_the_same_handler_is_connected_multiple_times_it_will_be_called_only_once()
    handler = function ()
                  handler_counter = handler_counter + 1
              end

    signal:connect(handler)
    signal:connect(handler)
    signal:connect(handler)
    signal:emit()
    assert_equal(1, handler_counter)
end


function test_if_the_same_handler_is_connected_multiple_times_it_has_to_be_disconnected_only_once()
    handler = function ()
                  handler_counter = handler_counter + 1
              end
    
    signal:connect(handler)
    signal:connect(handler)
    signal:connect(handler)
    signal:emit()
    assert_equal(1, handler_counter)
    signal:disconnect(handler)
    signal:emit()
    assert_equal(1, handler_counter)
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


function test_if_you_disconnect_a_handler_that_is_not_connected_nothing_happens()
    handler  = function ()
                  assert_equal(0, handler_counter)
                  handler_counter = handler_counter + 1
               end
    signal:disconnect(handler)
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


function test_if_you_block_a_handler_that_does_not_exist_nothing_happens()
    local handler = function () handler_counter = handler_counter + 1 end
    signal:block(handler)
end


function test_if_you_unblock_a_handler_that_does_not_exist_nothing_happens()
    local handler = function () handler_counter = handler_counter + 1 end
    signal:unblock(handler)
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


function test_set_up_functions_are_always_called_before_the_handlers()
    handler1 = function ()
                  assert_equal(0, handler_counter)
                  handler_counter = handler_counter + 1
               end

    handler2 = function ()
                  assert_equal(1, handler_counter)
                  handler_counter = handler_counter + 1
               end

    set_up =   function ()
                  assert_equal(0 , handler_counter)
               end

    signal:connect(handler1)
    signal:connect(handler2)
    signal:add_set_up(set_up)
    signal:emit()
end


function test_the_same_set_up_can_be_added_on_multiple_signals()
    local set_up = function () handler_counter = handler_counter + 1 end
    local signal2 = Signal:new()

    signal:add_set_up(set_up)
    signal2:add_set_up(set_up)

    assert_equal(0, handler_counter)
    signal:emit()
    assert_equal(1, handler_counter)
    signal2:emit()
    assert_equal(2, handler_counter)
end


function test_if_the_same_set_up_is_added_multiple_times_it_will_be_called_only_once()
    set_up = function ()
                 handler_counter = handler_counter + 1
             end
    
    signal:add_set_up(set_up)
    signal:add_set_up(set_up)
    signal:add_set_up(set_up)
    signal:emit()
    assert_equal(1, handler_counter)
end


function test_if_the_same_set_up_is_added_multiple_times_it_has_to_be_removed_only_once()
    set_up = function ()
                 handler_counter = handler_counter + 1
             end
                  
    signal:add_set_up(set_up)
    signal:add_set_up(set_up)
    signal:add_set_up(set_up)
    signal:emit()
    assert_equal(1, handler_counter)
    signal:remove_set_up(set_up)
    signal:emit()
    assert_equal(1, handler_counter)
end


function test_set_up_functions_are_called_on_the_order_they_are_inserted()
    handler  = function ()
                  assert_equal(2, handler_counter)
                  handler_counter = handler_counter + 1
               end

    set_up1 = function ()
                  assert_equal(0, handler_counter)
                  handler_counter = handler_counter + 1
               end

    set_up2 = function ()
                  assert_equal(1, handler_counter)
                  handler_counter = handler_counter + 1
               end

    signal:connect(handler)
    signal:add_set_up(set_up1)
    signal:add_set_up(set_up2)
    signal:emit()

end


function test_if_you_remove_a_set_up_that_does_not_exist_nothing_happens()
    set_up   = function ()
                  assert_equal(0, handler_counter)
               end

    signal:remove_set_up(set_up)
end


function test_after_removing_a_set_up_function_the_order_of_the_set_ups_remain_the_same()
    set_up1 = function ()
                  assert_equal(0, handler_counter)
                  handler_counter = handler_counter + 1
               end

    set_up2 = function ()
                  assert_equal(1, handler_counter)
                  handler_counter = handler_counter + 1
               end

    local offset = 0
    set_up3 = function ()
                  assert_equal(2 - offset, handler_counter)
                  handler_counter = handler_counter + 1
               end

    signal:add_set_up(set_up1)
    signal:add_set_up(set_up2)
    signal:add_set_up(set_up3)
    signal:emit()

    signal:remove_set_up(set_up2)
    offset = 1; handler_counter = 0
    signal:emit()

end


function test_set_up_functions_are_called_only_once_before_the_handlers()
    handler1 = function ()
                  assert_equal(1, handler_counter)
                  handler_counter = handler_counter + 1
               end

    handler2 = function ()
                  assert_equal(2, handler_counter)
                  handler_counter = handler_counter + 1
               end

    set_up =   function ()
                  assert_equal(0 , handler_counter)
                  handler_counter = handler_counter + 1
               end

    signal:connect(handler1)
    signal:connect(handler2)
    signal:add_set_up(set_up)
    signal:emit()
end


function test_no_emission_data_is_passed_to_the_set_up_functions()
    handler = function (arg)
                  assert_not_equal(nil, arg)
              end

    set_up =  function (arg)
                  assert_equal(nil, arg)
              end

    signal:connect(handler)
    signal:add_set_up(set_up)
    signal:emit("some_data")
end


function test_after_being_removed_a_set_up_function_wont_be_called_anymore()
    set_up1 = function ()
                  assert_equal(0, handler_counter)
                  handler_counter = handler_counter + 1
               end

    set_up2 = function ()
                  assert_equal(1, handler_counter)
                  handler_counter = handler_counter + 1
               end

    local offset = 0
    set_up3 = function ()
                  assert_equal(2 - offset, handler_counter)
                  handler_counter = handler_counter + 1
               end

    signal:add_set_up(set_up1)
    signal:add_set_up(set_up2)
    signal:add_set_up(set_up3)
    signal:emit()

    signal:remove_set_up(set_up2)
    offset = 1; handler_counter = 0
    signal:emit()
end


function test_set_up_functions_return_values_are_not_passed_to_the_accumulator()
--TODO
end


function test_tear_down_functions_are_always_called_after_the_handlers()
    handler1 = function ()
                  assert_equal(0, handler_counter)
                  handler_counter = handler_counter + 1
               end

    handler2 = function ()
                  assert_equal(1, handler_counter)
                  handler_counter = handler_counter + 1
               end

    tear_down = function ()
                  assert_equal(2 , handler_counter)
                  handler_counter = handler_counter + 1
                end

    signal:connect(handler1)
    signal:connect(handler2)
    signal:add_tear_down(tear_down)
    signal:emit()
    assert_equal(3, handler_counter)
end


function test_the_same_tear_down_can_be_added_on_multiple_signals()
    local tear_down = function () handler_counter = handler_counter + 1 end
    local signal2 = Signal:new()

    signal:add_tear_down(tear_down)
    signal2:add_tear_down(tear_down)

    assert_equal(0, handler_counter)
    signal:emit()
    assert_equal(1, handler_counter)
    signal2:emit()
    assert_equal(2, handler_counter)
end


function test_tear_down_functions_are_called_only_once_after_the_handlers()
    handler1 = function ()
                  assert_equal(0, handler_counter)
                  handler_counter = handler_counter + 1
               end

    handler2 = function ()
                  assert_equal(1, handler_counter)
                  handler_counter = handler_counter + 1
               end

    tear_down = function ()
                  assert_equal(2 , handler_counter)
                  handler_counter = handler_counter + 1
                end

    signal:connect(handler1)
    signal:connect(handler2)
    signal:add_tear_down(tear_down)
    signal:emit()
    assert_equal(3, handler_counter)
end


function test_no_emission_data_is_passed_to_the_tear_down_functions()
    handler   = function (arg)
                  assert_not_equal(nil, arg)
              end

    tear_down = function (arg)
                  assert_equal(nil, arg)
              end

    signal:connect(handler)
    signal:add_tear_down(tear_down)
    signal:emit("some_data")
end


function test_after_being_removed_a_tear_down_function_wont_be_called_anymore()
    tear_down1 = function ()
                  assert_equal(0, handler_counter)
                  handler_counter = handler_counter + 1
               end

    tear_down2 = function ()
                  assert_equal(1, handler_counter)
                  handler_counter = handler_counter + 1
               end

    local offset = 0
    tear_down3 = function ()
                  assert_equal(2 - offset, handler_counter)
                  handler_counter = handler_counter + 1
               end

    signal:add_tear_down(tear_down1)
    signal:add_tear_down(tear_down2)
    signal:add_tear_down(tear_down3)
    signal:emit()
    assert_equal(3, handler_counter)

    signal:remove_tear_down(tear_down2)
    offset = 1; handler_counter = 0
    signal:emit()
    assert_equal(2, handler_counter)

end


function test_tear_down_functions_return_values_are_not_passed_to_the_accumulator()
--TODO
end


function test_if_the_same_tear_down_is_added_multiple_times_it_will_be_called_only_once()
    tear_down = function ()
                    handler_counter = handler_counter + 1
                end
                  
    signal:add_tear_down(tear_down)
    signal:add_tear_down(tear_down)
    signal:add_tear_down(tear_down)
    signal:emit()
    assert_equal(1, handler_counter)
end


function test_if_the_same_tear_down_is_added_multiple_times_it_has_to_be_removed_only_once()
    tear_down = function ()
                    handler_counter = handler_counter + 1
                end

    signal:add_tear_down(tear_down)
    signal:add_tear_down(tear_down)
    signal:add_tear_down(tear_down)
    signal:emit()
    assert_equal(1, handler_counter)
    signal:remove_tear_down(tear_down)
    signal:emit()
    assert_equal(1, handler_counter)
end


function test_tear_down_functions_are_called_on_the_order_they_are_inserted()
    tear_down1 = function ()
                  assert_equal(0, handler_counter)
                  handler_counter = handler_counter + 1
               end

    tear_down2 = function ()
                  assert_equal(1, handler_counter)
                  handler_counter = handler_counter + 1
               end

    tear_down3 = function ()
                  assert_equal(2, handler_counter)
                  handler_counter = handler_counter + 1
               end

    assert_equal(0, handler_counter)
    signal:add_tear_down(tear_down1)
    signal:add_tear_down(tear_down2)
    signal:add_tear_down(tear_down3)
    signal:emit()
    assert_equal(3, handler_counter)
end


function test_after_removing_a_tear_down_function_the_order_of_the_tear_downs_remain_the_same()
    tear_down1 = function ()
                  assert_equal(0, handler_counter)
                  handler_counter = handler_counter + 1
               end

    tear_down2 = function ()
                  assert_equal(1, handler_counter)
                  handler_counter = handler_counter + 1
               end

    local offset = 0
    tear_down3 = function ()
                  assert_equal(2 - offset, handler_counter)
                  handler_counter = handler_counter + 1
               end

    assert_equal(0, handler_counter)
    signal:add_tear_down(tear_down1)
    signal:add_tear_down(tear_down2)
    signal:add_tear_down(tear_down3)
    signal:emit()
    assert_equal(3, handler_counter)

    signal:remove_tear_down(tear_down2)
    offset = 1; handler_counter = 0
    signal:emit()
    assert_equal(2, handler_counter)
end


function test_if_you_remove_a_tear_down_that_does_not_exist_nothing_happens()
    tear_down  = function ()
                  assert_equal(0, handler_counter)
               end

    signal:remove_tear_down(tear_down)
end

lunit.main()
