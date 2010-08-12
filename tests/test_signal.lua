--------------------------------------------------------------------------------

-- Copyright (C) 2010 Tiago Katcipis <tiagokatcipis@gmail.com>
-- Copyright (C) 2010 Paulo Pizarro  <paulo.pizarro@gmail.com>

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
-- along with LuaNotify.  If not, see <http://www.gnu.org/licenses/>.
---------------------------------------------------------------------------------

require "lunit"

module("signal_testcase", lunit.testcase, package.seeall)

local signal_module = require "notify.signal"


function setUp()
    signal = signal_module.new()
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


function test_handlers_are_called_on_a_queue_behavior()
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
    local signal2 = signal_module.new()
    
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


function test_pre_emit_functions_are_always_called_before_the_handlers()
    handler1 = function ()
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end

    handler2 = function ()
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    pre_emit =   function ()
                  assert_equal(0 , call_counter)
               end

    signal:connect(handler1)
    signal:connect(handler2)
    signal:add_pre_emit(pre_emit)
    signal:emit()
end


function test_the_same_pre_emit_can_be_added_on_multiple_signals()
    local pre_emit = function () call_counter = call_counter + 1 end
    local signal2 = signal_module.new()

    signal:add_pre_emit(pre_emit)
    signal2:add_pre_emit(pre_emit)

    assert_equal(0, call_counter)
    signal:emit()
    assert_equal(1, call_counter)
    signal2:emit()
    assert_equal(2, call_counter)
end


function test_if_the_same_pre_emit_is_added_multiple_times_it_will_be_called_only_once()
    pre_emit = function ()
                 call_counter = call_counter + 1
             end
    
    signal:add_pre_emit(pre_emit)
    signal:add_pre_emit(pre_emit)
    signal:add_pre_emit(pre_emit)
    signal:emit()
    assert_equal(1, call_counter)
end


function test_if_the_same_pre_emit_is_added_multiple_times_it_has_to_be_removed_only_once()
    pre_emit = function ()
                 call_counter = call_counter + 1
             end
                  
    signal:add_pre_emit(pre_emit)
    signal:add_pre_emit(pre_emit)
    signal:add_pre_emit(pre_emit)
    signal:emit()
    assert_equal(1, call_counter)
    signal:remove_pre_emit(pre_emit)
    signal:emit()
    assert_equal(1, call_counter)
end


function test_pre_emit_functions_are_called_on_a_queue_behavior()
    handler  = function ()
                  assert_equal(2, call_counter)
                  call_counter = call_counter + 1
               end

    pre_emit1 = function ()
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end

    pre_emit2 = function ()
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    signal:connect(handler)
    signal:add_pre_emit(pre_emit1)
    signal:add_pre_emit(pre_emit2)
    signal:emit()
end


function test_if_you_remove_a_pre_emit_that_does_not_exist_nothing_happens()
    pre_emit   = function ()
                  assert_equal(0, call_counter)
               end

    signal:remove_pre_emit(pre_emit)
end


function test_after_removing_a_pre_emit_function_the_order_of_the_pre_emits_remain_the_same()
    pre_emit1 = function ()
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end

    pre_emit2 = function ()
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    local offset = 0
    pre_emit3 = function ()
                  assert_equal(2 - offset, call_counter)
                  call_counter = call_counter + 1
               end

    signal:add_pre_emit(pre_emit1)
    signal:add_pre_emit(pre_emit2)
    signal:add_pre_emit(pre_emit3)
    signal:emit()

    signal:remove_pre_emit(pre_emit2)
    offset = 1; call_counter = 0
    signal:emit()

end


function test_pre_emit_functions_are_called_only_once_before_the_handlers()
    handler1 = function ()
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    handler2 = function ()
                  assert_equal(2, call_counter)
                  call_counter = call_counter + 1
               end

    pre_emit =   function ()
                  assert_equal(0 , call_counter)
                  call_counter = call_counter + 1
               end

    signal:connect(handler1)
    signal:connect(handler2)
    signal:add_pre_emit(pre_emit)
    signal:emit()
end


function test_no_emission_data_is_passed_to_the_pre_emit_functions()
    handler = function (arg)
                  assert_not_equal(nil, arg)
              end

    pre_emit =  function (arg)
                  assert_equal(nil, arg)
              end

    signal:connect(handler)
    signal:add_pre_emit(pre_emit)
    signal:emit("some_data")
end


function test_after_being_removed_a_pre_emit_function_wont_be_called_anymore()
    pre_emit1 = function ()
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end

    pre_emit2 = function ()
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    local offset = 0
    pre_emit3 = function ()
                  assert_equal(2 - offset, call_counter)
                  call_counter = call_counter + 1
               end

    signal:add_pre_emit(pre_emit1)
    signal:add_pre_emit(pre_emit2)
    signal:add_pre_emit(pre_emit3)
    signal:emit()

    signal:remove_pre_emit(pre_emit2)
    offset = 1; call_counter = 0
    signal:emit()
end


function test_post_emit_functions_are_always_called_after_the_handlers()
    handler1 = function ()
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end

    handler2 = function ()
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    post_emit = function ()
                  assert_equal(2 , call_counter)
                  call_counter = call_counter + 1
                end

    signal:connect(handler1)
    signal:connect(handler2)
    signal:add_post_emit(post_emit)
    signal:emit()
    assert_equal(3, call_counter)
end


function test_the_same_post_emit_can_be_added_on_multiple_signals()
    local post_emit = function () call_counter = call_counter + 1 end
    local signal2 = signal_module.new()

    signal:add_post_emit(post_emit)
    signal2:add_post_emit(post_emit)

    assert_equal(0, call_counter)
    signal:emit()
    assert_equal(1, call_counter)
    signal2:emit()
    assert_equal(2, call_counter)
end


function test_post_emit_functions_are_called_only_once_after_the_handlers()
    handler1 = function ()
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end

    handler2 = function ()
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    post_emit = function ()
                  assert_equal(2 , call_counter)
                  call_counter = call_counter + 1
                end

    signal:connect(handler1)
    signal:connect(handler2)
    signal:add_post_emit(post_emit)
    signal:emit()
    assert_equal(3, call_counter)
end


function test_no_emission_data_is_passed_to_the_post_emit_functions()
    handler   = function (arg)
                  assert_not_equal(nil, arg)
              end

    post_emit = function (arg)
                  assert_equal(nil, arg)
              end

    signal:connect(handler)
    signal:add_post_emit(post_emit)
    signal:emit("some_data")
end


function test_after_being_removed_a_post_emit_function_wont_be_called_anymore()
    post_emit1 = function ()
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end

    post_emit2 = function ()
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    local offset = 0
    post_emit3 = function ()
                  assert_equal(2 - offset, call_counter)
                  call_counter = call_counter + 1
               end

    signal:add_post_emit(post_emit3)
    signal:add_post_emit(post_emit2)
    signal:add_post_emit(post_emit1)
    signal:emit()
    assert_equal(3, call_counter)

    signal:remove_post_emit(post_emit2)
    offset = 1; call_counter = 0
    signal:emit()
    assert_equal(2, call_counter)

end


function test_if_the_same_post_emit_is_added_multiple_times_it_will_be_called_only_once()
    post_emit = function ()
                    call_counter = call_counter + 1
                end
                  
    signal:add_post_emit(post_emit)
    signal:add_post_emit(post_emit)
    signal:add_post_emit(post_emit)
    signal:emit()
    assert_equal(1, call_counter)
end


function test_if_the_same_post_emit_is_added_multiple_times_it_has_to_be_removed_only_once()
    post_emit = function ()
                    call_counter = call_counter + 1
                end

    signal:add_post_emit(post_emit)
    signal:add_post_emit(post_emit)
    signal:add_post_emit(post_emit)
    signal:emit()
    assert_equal(1, call_counter)
    signal:remove_post_emit(post_emit)
    signal:emit()
    assert_equal(1, call_counter)
end


function test_post_emit_functions_are_called_on_a_stack_behavior()
    post_emit1 = function ()
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end

    post_emit2 = function ()
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    post_emit3 = function ()
                  assert_equal(2, call_counter)
                  call_counter = call_counter + 1
               end

    assert_equal(0, call_counter)
    signal:add_post_emit(post_emit3)
    signal:add_post_emit(post_emit2)
    signal:add_post_emit(post_emit1)
    signal:emit()
    assert_equal(3, call_counter)
end


function test_after_removing_a_post_emit_function_the_order_of_the_post_emits_remain_the_same()
    post_emit1 = function ()
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end

    post_emit2 = function ()
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    local offset = 0
    post_emit3 = function ()
                  assert_equal(2 - offset, call_counter)
                  call_counter = call_counter + 1
               end

    assert_equal(0, call_counter)
    signal:add_post_emit(post_emit3)
    signal:add_post_emit(post_emit2)
    signal:add_post_emit(post_emit1)
    signal:emit()
    assert_equal(3, call_counter)

    signal:remove_post_emit(post_emit2)
    offset = 1; call_counter = 0
    signal:emit()
    assert_equal(2, call_counter)
end


function test_if_you_remove_a_post_emit_that_does_not_exist_nothing_happens()
    post_emit  = function ()
                  assert_equal(0, call_counter)
               end

    signal:remove_post_emit(post_emit)
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


function test_pre_emit_functions_return_values_are_not_passed_to_the_accumulator()
    local pre_emit = function ()
                       return 1
                   end

    local handler = function ()
                       return 2
                    end

    local accumulator = function (arg)
                            assert_equal(arg, 2)
                        end

    signal:add_pre_emit(pre_emit)
    signal:connect(handler)
    signal:emit_with_accumulator(accumulator)
end


function test_post_emit_functions_return_values_are_not_passed_to_the_accumulator()
    local post_emit = function ()
                          return 1
                      end

    local handler = function ()
                       return 2
                    end

    local accumulator = function (arg)
                            assert_equal(arg, 2)
                        end

    signal:add_post_emit(post_emit)
    signal:connect(handler)
    signal:emit_with_accumulator(accumulator)
end


function test_if_a_signal_is_stopped_no_more_handlers_are_called_on_that_emission()
    
    local handler1 = function ()
                         assert_equal(0, call_counter)
                         call_counter = call_counter + 1
                     end

    local handler2 = function ()
                         assert_equal(1, call_counter)
                         call_counter = call_counter + 1
                         signal:stop()
                     end

    local handler3 = function ()
                         call_counter = call_counter + 1
                     end

    signal:connect(handler1)
    signal:connect(handler2)
    signal:connect(handler3)

    assert_equal(0, call_counter)
    signal:emit()
    assert_equal(2, call_counter) 
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


function test_the_signal_emission_can_be_stopped_inside_a_pre_emit()
    local pre_emit = function ()
                       assert_equal(0, call_counter)
                       call_counter = call_counter + 1
                       signal:stop()
                   end

    local handler = function ()
                        assert_equal(1, call_counter)
                        call_counter = call_counter + 1
                    end

    signal:add_pre_emit(pre_emit)
    signal:connect(handler)
    signal:emit()
    assert_equal(1, call_counter)
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


function test_stopping_a_signal_will_not_stop_the_pre_emit_functions()
    local pre_emit1 = function ()
                        assert_equal(0, call_counter)
                        call_counter = call_counter + 1
                        signal:stop()
                    end

    local pre_emit2 = function ()
                        assert_equal(1, call_counter)
                        call_counter = call_counter + 1
                    end

    local handler = function ()
                        assert_equal(2, call_counter)
                        call_counter = call_counter + 1
                    end

    signal:add_pre_emit(pre_emit1)
    signal:add_pre_emit(pre_emit2)
    signal:connect(handler)
    signal:emit()
    assert_equal(2, call_counter)
end


function test_stopping_a_signal_will_not_stop_the_post_emit_functions()
    local post_emit = function ()
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

    signal:add_post_emit(post_emit)
    signal:connect(handler1)
    signal:connect(handler2)
    signal:emit()
    assert_equal(2, call_counter)
end


lunit.main()
