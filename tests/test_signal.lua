---------------------------------------------------------------------------------
-- Copyright (C) 2010 Digitro Corporation <www.digitro.com.br>
-- 
-- @author Paulo Pizarro  <paulo.pizarro@gmail.com>
-- @author Tiago Katcipis <tiagokatcipis@gmail.com>
 
-- This file is part of LuaNotify.
 
-- LuaNotify is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
 
-- LuaNotify is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Lesser General Public License for more details.
 
-- You should have received a copy of the GNU Lesser General Public License
-- along with Luasofia.  If not, see <http://www.gnu.org/licenses/>.
---------------------------------------------------------------------------------

require "lunit"
require "luanotify.signal"

module("signal_testcase", lunit.testcase, package.seeall)

function setUp()
    signal = Signal:new()
    call_counter = 0
end

function tearDown()
    signal = nil
end


function test_if_a_handler_function_is_connected_it_will_always_be_called_when_a_emission_occurs()

    local handler = function () call_counter = call_counter + 1 end

    signal:connect(handler)
    assert_equal(0, call_counter)
    signal:emit()
    assert_equal(1, call_counter)
    signal:emit()
    assert_equal(2, call_counter) 
end


function test_if_there_is_no_handler_connected_emission_does_nothing()
    assert_equal(0, call_counter)
    signal:emit()
    assert_equal(0, call_counter)
end


function test_handlers_are_called_on_the_order_they_are_inserted()
    handler1 = function ()
                   assert_equal(0, call_counter)
                   call_counter = call_counter + 1
               end

    handler2 = function ()
                   assert_equal(1, call_counter)
                   call_counter = call_counter + 1
               end

    handler3 = function ()
                   assert_equal(2, call_counter)
                   call_counter = call_counter + 1
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
                  call_counter = call_counter + 1
              end

    signal:connect(handler)
    signal:connect(handler)
    signal:connect(handler)
    signal:emit()
    assert_equal(1, call_counter)
end


function test_if_the_same_handler_is_connected_multiple_times_it_has_to_be_disconnected_only_once()
    handler = function ()
                  call_counter = call_counter + 1
              end
    
    signal:connect(handler)
    signal:connect(handler)
    signal:connect(handler)
    signal:emit()
    assert_equal(1, call_counter)
    signal:disconnect(handler)
    signal:emit()
    assert_equal(1, call_counter)
end


function test_the_same_handler_can_be_connected_on_multiple_signals()
    local handler = function () call_counter = call_counter + 1 end
    local signal2 = Signal:new()
    
    signal:connect(handler)
    signal2:connect(handler)

    assert_equal(0, call_counter)
    signal:emit()
    assert_equal(1, call_counter)
    signal2:emit()
    assert_equal(2, call_counter)
end


function test_if_you_disconnect_a_handler_that_is_not_connected_nothing_happens()
    handler  = function ()
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end
    signal:disconnect(handler)
end


function test_if_a_handler_is_disconnected_the_order_of_the_remaining_handlers_wont_change()
    handler1 = function ()
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end

    handler2 = function ()
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    handler3 = function (offset)
                  local offset = offset or 0
                  assert_equal(2 - offset, call_counter)
                  call_counter = call_counter + 1
               end

    signal:connect(handler1)
    signal:connect(handler2)
    signal:connect(handler3)
    signal:emit()

    signal:disconnect(handler2)
    call_counter = 0
    signal:emit(1)
end


function test_if_a_handler_is_disconnected_it_will_not_be_called_anymore()
    local handler = function () call_counter = call_counter + 1 end

    signal:connect(handler)
    assert_equal(0, call_counter)
    signal:emit()
    assert_equal(1, call_counter)
    signal:disconnect(handler)
    signal:emit()
    assert_equal(1, call_counter)
end


function test_if_a_handler_got_blocked_it_wont_be_called_on_emission()
    local handler = function () call_counter = call_counter + 1 end

    signal:connect(handler)
    assert_equal(0, call_counter)
    signal:emit()
    assert_equal(1, call_counter)
    signal:block(handler)
    signal:emit()
    assert_equal(1, call_counter)
    signal:emit()
    assert_equal(1, call_counter)
end


function test_if_you_block_a_handler_that_does_not_exist_nothing_happens()
    local handler = function () call_counter = call_counter + 1 end
    signal:block(handler)
end


function test_if_you_unblock_a_handler_that_does_not_exist_nothing_happens()
    local handler = function () call_counter = call_counter + 1 end
    signal:unblock(handler)
end


function test_a_blocked_handler_can_be_unblocked()
    local handler = function () call_counter = call_counter + 1 end

    signal:connect(handler)
    assert_equal(0, call_counter)
    signal:emit()
    assert_equal(1, call_counter)
    signal:block(handler)
    signal:emit()
    assert_equal(1, call_counter)
    signal:unblock(handler)
    signal:emit()
    assert_equal(2, call_counter)
end


function test_a_unblocked_handler_will_be_called_on_its_original_position()
    handler1 = function ()
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end

    handler2 = function ()
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    handler3 = function (offset)
                  local offset = offset or 0
                  assert_equal(2 - offset, call_counter)
                  call_counter = call_counter + 1
               end

    signal:connect(handler1)
    signal:connect(handler2)
    signal:connect(handler3)
    signal:block(handler2)
    signal:emit(1)
 
    call_counter = 0
    signal:unblock(handler2)
    signal:emit()   
end


function test_a_handler_must_be_unblocked_the_same_times_it_has_been_blocked()
    local handler = function () call_counter = call_counter + 1 end

    signal:connect(handler)
    signal:block(handler)
    signal:block(handler)
    signal:block(handler)

    signal:emit()
    assert_equal(0, call_counter)
    
    signal:unblock(handler)
    signal:emit()
    assert_equal(0, call_counter)

    signal:unblock(handler)
    signal:emit()
    assert_equal(0, call_counter)

    signal:unblock(handler)
    signal:emit()
    assert_equal(1, call_counter)
end


function test_set_up_functions_are_always_called_before_the_handlers()
    handler1 = function ()
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end

    handler2 = function ()
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    set_up =   function ()
                  assert_equal(0 , call_counter)
               end

    signal:connect(handler1)
    signal:connect(handler2)
    signal:add_set_up(set_up)
    signal:emit()
end


function test_the_same_set_up_can_be_added_on_multiple_signals()
    local set_up = function () call_counter = call_counter + 1 end
    local signal2 = Signal:new()

    signal:add_set_up(set_up)
    signal2:add_set_up(set_up)

    assert_equal(0, call_counter)
    signal:emit()
    assert_equal(1, call_counter)
    signal2:emit()
    assert_equal(2, call_counter)
end


function test_if_the_same_set_up_is_added_multiple_times_it_will_be_called_only_once()
    set_up = function ()
                 call_counter = call_counter + 1
             end
    
    signal:add_set_up(set_up)
    signal:add_set_up(set_up)
    signal:add_set_up(set_up)
    signal:emit()
    assert_equal(1, call_counter)
end


function test_if_the_same_set_up_is_added_multiple_times_it_has_to_be_removed_only_once()
    set_up = function ()
                 call_counter = call_counter + 1
             end
                  
    signal:add_set_up(set_up)
    signal:add_set_up(set_up)
    signal:add_set_up(set_up)
    signal:emit()
    assert_equal(1, call_counter)
    signal:remove_set_up(set_up)
    signal:emit()
    assert_equal(1, call_counter)
end


function test_set_up_functions_are_called_on_the_order_they_are_inserted()
    handler  = function ()
                  assert_equal(2, call_counter)
                  call_counter = call_counter + 1
               end

    set_up1 = function ()
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end

    set_up2 = function ()
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    signal:connect(handler)
    signal:add_set_up(set_up1)
    signal:add_set_up(set_up2)
    signal:emit()
end


function test_if_you_remove_a_set_up_that_does_not_exist_nothing_happens()
    set_up   = function ()
                  assert_equal(0, call_counter)
               end

    signal:remove_set_up(set_up)
end


function test_after_removing_a_set_up_function_the_order_of_the_set_ups_remain_the_same()
    set_up1 = function ()
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end

    set_up2 = function ()
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    local offset = 0
    set_up3 = function ()
                  assert_equal(2 - offset, call_counter)
                  call_counter = call_counter + 1
               end

    signal:add_set_up(set_up1)
    signal:add_set_up(set_up2)
    signal:add_set_up(set_up3)
    signal:emit()

    signal:remove_set_up(set_up2)
    offset = 1; call_counter = 0
    signal:emit()

end


function test_set_up_functions_are_called_only_once_before_the_handlers()
    handler1 = function ()
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    handler2 = function ()
                  assert_equal(2, call_counter)
                  call_counter = call_counter + 1
               end

    set_up =   function ()
                  assert_equal(0 , call_counter)
                  call_counter = call_counter + 1
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
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end

    set_up2 = function ()
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    local offset = 0
    set_up3 = function ()
                  assert_equal(2 - offset, call_counter)
                  call_counter = call_counter + 1
               end

    signal:add_set_up(set_up1)
    signal:add_set_up(set_up2)
    signal:add_set_up(set_up3)
    signal:emit()

    signal:remove_set_up(set_up2)
    offset = 1; call_counter = 0
    signal:emit()
end


function test_tear_down_functions_are_always_called_after_the_handlers()
    handler1 = function ()
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end

    handler2 = function ()
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    tear_down = function ()
                  assert_equal(2 , call_counter)
                  call_counter = call_counter + 1
                end

    signal:connect(handler1)
    signal:connect(handler2)
    signal:add_tear_down(tear_down)
    signal:emit()
    assert_equal(3, call_counter)
end


function test_the_same_tear_down_can_be_added_on_multiple_signals()
    local tear_down = function () call_counter = call_counter + 1 end
    local signal2 = Signal:new()

    signal:add_tear_down(tear_down)
    signal2:add_tear_down(tear_down)

    assert_equal(0, call_counter)
    signal:emit()
    assert_equal(1, call_counter)
    signal2:emit()
    assert_equal(2, call_counter)
end


function test_tear_down_functions_are_called_only_once_after_the_handlers()
    handler1 = function ()
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end

    handler2 = function ()
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    tear_down = function ()
                  assert_equal(2 , call_counter)
                  call_counter = call_counter + 1
                end

    signal:connect(handler1)
    signal:connect(handler2)
    signal:add_tear_down(tear_down)
    signal:emit()
    assert_equal(3, call_counter)
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
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end

    tear_down2 = function ()
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    local offset = 0
    tear_down3 = function ()
                  assert_equal(2 - offset, call_counter)
                  call_counter = call_counter + 1
               end

    signal:add_tear_down(tear_down1)
    signal:add_tear_down(tear_down2)
    signal:add_tear_down(tear_down3)
    signal:emit()
    assert_equal(3, call_counter)

    signal:remove_tear_down(tear_down2)
    offset = 1; call_counter = 0
    signal:emit()
    assert_equal(2, call_counter)

end


function test_if_the_same_tear_down_is_added_multiple_times_it_will_be_called_only_once()
    tear_down = function ()
                    call_counter = call_counter + 1
                end
                  
    signal:add_tear_down(tear_down)
    signal:add_tear_down(tear_down)
    signal:add_tear_down(tear_down)
    signal:emit()
    assert_equal(1, call_counter)
end


function test_if_the_same_tear_down_is_added_multiple_times_it_has_to_be_removed_only_once()
    tear_down = function ()
                    call_counter = call_counter + 1
                end

    signal:add_tear_down(tear_down)
    signal:add_tear_down(tear_down)
    signal:add_tear_down(tear_down)
    signal:emit()
    assert_equal(1, call_counter)
    signal:remove_tear_down(tear_down)
    signal:emit()
    assert_equal(1, call_counter)
end


function test_tear_down_functions_are_called_on_the_order_they_are_inserted()
    tear_down1 = function ()
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end

    tear_down2 = function ()
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    tear_down3 = function ()
                  assert_equal(2, call_counter)
                  call_counter = call_counter + 1
               end

    assert_equal(0, call_counter)
    signal:add_tear_down(tear_down1)
    signal:add_tear_down(tear_down2)
    signal:add_tear_down(tear_down3)
    signal:emit()
    assert_equal(3, call_counter)
end


function test_after_removing_a_tear_down_function_the_order_of_the_tear_downs_remain_the_same()
    tear_down1 = function ()
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end

    tear_down2 = function ()
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    local offset = 0
    tear_down3 = function ()
                  assert_equal(2 - offset, call_counter)
                  call_counter = call_counter + 1
               end

    assert_equal(0, call_counter)
    signal:add_tear_down(tear_down1)
    signal:add_tear_down(tear_down2)
    signal:add_tear_down(tear_down3)
    signal:emit()
    assert_equal(3, call_counter)

    signal:remove_tear_down(tear_down2)
    offset = 1; call_counter = 0
    signal:emit()
    assert_equal(2, call_counter)
end


function test_if_you_remove_a_tear_down_that_does_not_exist_nothing_happens()
    tear_down  = function ()
                  assert_equal(0, call_counter)
               end

    signal:remove_tear_down(tear_down)
end


function test_if_the_accumulator_is_not_function_the_handlers_are_not_called()
    local handler = function ()
                        assert_equal(0, call_counter)
                        call_counter = call_counter + 1
                        return call_counter
                    end

    signal:connect(handler)
    signal:emit_with_accumulator()
    assert_equal(0, call_counter)
end

function test_the_return_value_of_each_handler_is_passed_to_the_accumulator()
    local handler1 = function ()
                         assert_equal(0, call_counter)
                         call_counter = call_counter + 1
                         return call_counter
                     end

    local handler2 = function ()
                         assert_equal(1, call_counter)
                         call_counter = call_counter + 1
                         return call_counter
                     end

    local counter = 0

    local accumulator = function (arg1)
                            counter = counter + arg1
                        end

    signal:connect(handler1)
    signal:connect(handler2)
    signal:emit_with_accumulator(accumulator)
    assert_equal(2, call_counter)
    assert_equal(3, counter)
end


function test_after_the_execution_of_each_handler_the_accumulator_is_called()
    local handler1 = function ()
                         call_counter = call_counter + 1
                     end

    local handler2 = function ()
                         call_counter = call_counter + 1
                     end

    local counter = 0

    local accumulator = function ()
                            counter = counter + 1
                            assert_equal(call_counter, counter)
                        end

    signal:connect(handler1)
    signal:connect(handler2)
    signal:emit_with_accumulator(accumulator)
end


function test_even_when_the_handler_returns_nil_it_is_repassed_to_the_accumulator()
    local handler = function ()
                    end

    local accumulator = function (arg)
                            assert_equal(arg, nil)
                        end

    signal:connect(handler)
    signal:emit_with_accumulator(accumulator)
end


function test_the_handlers_can_return_multiple_values_to_the_accumulator()
    local handler = function ()
                        return 1, 2
                    end

    local accumulator = function (arg1, arg2)
                            assert_equal(arg1, 1)
                            assert_equal(arg2, 2)
                        end

    signal:connect(handler)
    signal:emit_with_accumulator(accumulator)
end


function test_set_up_functions_return_values_are_not_passed_to_the_accumulator()
    local set_up = function ()
                       return 1
                   end

    local handler = function ()
                       return 2
                    end

    local accumulator = function (arg)
                            assert_equal(arg, 2)
                        end

    signal:add_set_up(set_up)
    signal:connect(handler)
    signal:emit_with_accumulator(accumulator)
end


function test_tear_down_functions_return_values_are_not_passed_to_the_accumulator()
    local tear_down = function ()
                          return 1
                      end

    local handler = function ()
                       return 2
                    end

    local accumulator = function (arg)
                            assert_equal(arg, 2)
                        end

    signal:add_tear_down(tear_down)
    signal:connect(handler)
    signal:emit_with_accumulator(accumulator)
end


function test_if_a_signal_is_stopped_no_more_handlers_are_called()
--TODO ???? stop() only do sense after emit() call 
end


function test_the_signal_emission_can_be_stopped_inside_a_handler()
    local handler1 = function ()
                         assert_equal(0, call_counter)
                         call_counter = call_counter + 1
                         signal:stop()
                     end

    local handler2 = function ()
                         assert_equal(1, call_counter)
                         call_counter = call_counter + 1
                     end

    signal:connect(handler1)
    signal:connect(handler2)
    signal:emit()
    assert_equal(1, call_counter)
end


function test_the_signal_emission_can_be_stopped_inside_a_set_up()
    local set_up = function ()
                       assert_equal(0, call_counter)
                       call_counter = call_counter + 1
                       signal:stop()
                   end

    local handler = function ()
                        assert_equal(1, call_counter)
                        call_counter = call_counter + 1
                    end

    signal:add_set_up(set_up)
    signal:connect(handler)
    signal:emit()
    assert_equal(1, call_counter)
end


function test_the_signal_emission_can_be_stopped_inside_a_tear_down()
--TODO ????? the handler functions already calleds
end


function test_the_signal_emission_can_be_stopped_inside_a_accumulator()
    local handler1 = function ()
                        assert_equal(0, call_counter)
                        call_counter = call_counter + 1
                     end

    local handler2 = function ()
                        assert_equal(1, call_counter)
                        call_counter = call_counter + 1
                     end

    local accumulator = function ()
                            signal:stop()
                        end

    signal:connect(handler1)
    signal:connect(handler2)
    signal:emit_with_accumulator(accumulator)
    assert_equal(1, call_counter)
end


function test_the_signal_emission_can_be_stopped_inside_a_coroutine()
--TODO ????
end


function test_stopping_a_signal_will_not_stop_the_set_up_functions()
    local set_up1 = function ()
                        assert_equal(0, call_counter)
                        call_counter = call_counter + 1
                        signal:stop()
                    end

    local set_up2 = function ()
                        assert_equal(1, call_counter)
                        call_counter = call_counter + 1
                    end

    local handler = function ()
                        assert_equal(2, call_counter)
                        call_counter = call_counter + 1
                    end

    signal:add_set_up(set_up1)
    signal:add_set_up(set_up2)
    signal:connect(handler)
    signal:emit()
    assert_equal(2, call_counter)
end


function test_stopping_a_signal_will_not_stop_the_tear_down_functions()
    local tear_down = function ()
                          assert_equal(1, call_counter)
                          call_counter = call_counter + 1
                      end

    local handler1 = function ()
                         assert_equal(0, call_counter)
                         call_counter = call_counter + 1
                         signal:stop()
                     end

    local handler2 = function ()
                         assert_equal(1, call_counter)
                         call_counter = call_counter + 1
                     end

    signal:add_tear_down(tear_down)
    signal:connect(handler1)
    signal:connect(handler2)
    signal:emit()
    assert_equal(2, call_counter)
end


lunit.main()
