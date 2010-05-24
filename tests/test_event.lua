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
local event = require "luanotify.event"

module("event_testcase", lunit.testcase, package.seeall)

function setUp()
    call_counter = 0
end

function tearDown()
    event.clear()
end


function test_if_a_handler_function_is_connected_to_a_event_it_will_always_be_called_when_that_event_emission_occurs()
    local handler = function (name) call_counter = call_counter + 1 end

    event.connect("luanotify", handler)
    event.connect("luanotify:event", handler)
    event.connect("luanotify:event:test", handler)
    assert_equal(0, call_counter)
    event.emit("luanotify")
    assert_equal(1, call_counter)
    event.emit("luanotify:event")
    assert_equal(3, call_counter)
    event.emit("luanotify:event:test")
    assert_equal(6, call_counter)
end


function test_you_can_have_one_handler_connected_only_on_a_subevent()
    local handler = function (name) call_counter = call_counter + 1 end

    event.connect("luanotify:event:test", handler)
    assert_equal(0, call_counter)
    event.emit("luanotify:event:test")
    assert_equal(1, call_counter)
end


function test_an_error_is_generated_if_you_connect_a_handler_that_is_not_a_function()
    local handler = "not a function"
    assert_error("connect: expected a function, got a "..type(handler), function () event.connect("test", handler) end)
end


function test_if_there_is_no_handler_connected_to_an_event_the_emission_of_the_event_does_nothing()
    assert_equal(0, call_counter)
    event.emit("luanotify")
    assert_equal(0, call_counter)
end


function test_handlers_connected_to_a_event_are_called_on_a_queue_behavior()
    local handler1 = function (name)
                   assert_equal(0, call_counter)
                   call_counter = call_counter + 1
               end

    local handler2 = function (name)
                   assert_equal(1, call_counter)
                   call_counter = call_counter + 1
               end

    local handler3 = function (name)
                   assert_equal(2, call_counter)
                   call_counter = call_counter + 1
               end

     event.connect("luanotify:event:test",handler1)
     event.connect("luanotify:event:test",handler2)
     event.connect("luanotify:event:test",handler3)
     event.emit("luanotify:event:test")
end


function test_handlers_receive_all_the_data_that_is_passed_on_emission()
    local handler  = function (arg1, arg2, arg3)
                   assert_equal("luanotify", arg1)
                   assert_equal("apple", arg2)
                   assert_equal("pineapple", arg3)
               end

    event.connect("luanotify", handler)
    event.emit("luanotify", "apple", "pineapple")
end


function test_the_first_parameter_given_to_a_handler_on_emission_is_always_the_name_of_the_emitted_event()
    local handler  = function (arg1, arg2)
                   assert_equal("luanotify:event", arg1)
               end

    event.connect("luanotify:event", handler)
    event.emit("luanotify:event", "pineapple")
end


function test_all_event_handlers_on_the_event_tree_receive_the_name_of_the_emitted_event_as_the_first_parameter()
    local event_name = { name = "luanotify:event:test" }

    local handler1  = function (arg1)
                   assert_equal(event_name.name, arg1)
               end
    local handler2  = function (arg1)
                   assert_equal(event_name.name, arg1)
               end
    local handler3  = function (arg1)
                   assert_equal(event_name.name, arg1)
               end

    event.connect("luanotify", handler1)
    event.connect("luanotify:event", handler2)
    event.connect("luanotify:event:test", handler3)

    event.emit(event_name.name)
    event_name.name = "luanotify:event"
    event.emit(event_name.name)
    event_name.name = "luanotify"
    event.emit(event_name.name)
end


function test_handlers_receive_all_the_data_that_is_passed_on_emission_on_the_order_it_was_on_emission_call()
    local handler1  = function (arg1, arg2)
                   assert_equal(0, call_counter)
                   call_counter = call_counter + 1
                   assert_equal("luanotify:event:test", arg1)
                   assert_equal("pineapple", arg2)
               end
    local handler2  = function (arg1, arg2)
                   assert_equal(1, call_counter)
                   call_counter = call_counter + 1
                   assert_equal("luanotify:event:test", arg1)
                   assert_equal("pineapple", arg2)
               end
    local handler3  = function (arg1, arg2)
                   assert_equal(2, call_counter)
                   call_counter = call_counter + 1
                   assert_equal("luanotify:event:test", arg1)
                   assert_equal("pineapple", arg2)
               end

    event.connect("luanotify", handler1)
    event.connect("luanotify:event", handler2)
    event.connect("luanotify:event:test", handler3)
    event.emit("luanotify:event:test", "pineapple")
end


function test_if_the_same_handler_is_connected_multiple_times_to_the_same_event_it_will_be_called_only_once()
    local handler = function (name)
                  call_counter = call_counter + 1
              end

    event.connect("luanotify", handler)
    event.connect("luanotify", handler)
    event.connect("luanotify", handler)
    event.emit("luanotify")
    assert_equal(1, call_counter)
    event.disconnect("luanotify", handler)
    event.emit("luanotify")
    assert_equal(1, call_counter)
end


function test_the_same_handler_function_can_be_connected_to_different_events()
    local handler = function (name) call_counter = call_counter + 1 end

    event.connect("luanotify:event:test1", handler)
    event.connect("luanotify:event:test2", handler)

    assert_equal(0, call_counter)
    event.emit("luanotify:event:test1")
    assert_equal(1, call_counter)
    event.emit("luanotify:event:test2")
    assert_equal(2, call_counter)
end


function test_if_the_same_handler_is_connected_multiple_times_to_the_same_event_it_has_to_be_disconnected_only_once()
    local handler = function (name)
                  call_counter = call_counter + 1
              end

    event.connect("luanotify", handler)
    event.connect("luanotify", handler)
    event.connect("luanotify", handler)
    event.emit("luanotify")
    assert_equal(1, call_counter)
    event.disconnect("luanotify", handler)
    event.emit("luanotify")
    assert_equal(1, call_counter)
end


function test_if_you_disconnect_a_handler_from_a_event_that_it_is_not_connected_nothing_happens()
    local handler  = function (name)
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end
    event.disconnect("luanotify", handler)
    assert_equal(0, call_counter)
end


function test_if_a_handler_is_disconnected_from_a_event_the_calling_order_of_the_remaining_handlers_wont_change()
    local handler1 = function (name)
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end

    local handler2 = function (name)
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    local handler3 = function (name, offset)
                  local offset = offset or 0
                  assert_equal(2 - offset, call_counter)
                  call_counter = call_counter + 1
               end

    event.connect("luanotify:event", handler1)
    event.connect("luanotify:event", handler2)
    event.connect("luanotify:event", handler3)
    event.emit("luanotify:event")

    event.disconnect("luanotify:event", handler2)
    call_counter = 0
    event.emit("luanotify:event", 1)
end


function test_if_a_handler_is_disconnected_from_a_event_it_will_not_be_called_anymore_when_that_event_emits()
    local handler = function (name)
                  call_counter = call_counter + 1
              end

    event.connect("luanotify", handler)
    event.connect("luanotify", handler)
    event.connect("luanotify", handler)
    event.emit("luanotify")
    assert_equal(1, call_counter)
    event.disconnect("luanotify", handler)
    event.emit("luanotify")
    assert_equal(1, call_counter)
end


function test_the_handler_function_must_be_disconnected_from_the_exact_same_event_it_was_connected_not_parent_events()
   local handler = function (name) call_counter = call_counter + 1 end

    event.connect("luanotify:event:test", handler)
    assert_equal(0, call_counter)
    event.emit("luanotify:event:test")
    assert_equal(1, call_counter)
    event.disconnect("luanotify:event", handler)
    event.emit("luanotify:event:test")
    assert_equal(2, call_counter)
end


function test_the_handler_function_must_be_disconnected_from_the_exact_same_event_it_was_connected_not_child_events()
   local handler = function (name) call_counter = call_counter + 1 end

    event.connect("luanotify:event", handler)
    assert_equal(0, call_counter)
    event.emit("luanotify:event:test")
    assert_equal(1, call_counter)
    event.disconnect("luanotify:event:test", handler)
    event.emit("luanotify:event:test")
    assert_equal(2, call_counter)
end


function test_if_a_handler_got_blocked_it_wont_be_called_on_emission()
    local handler = function (name) call_counter = call_counter + 1 end

    event.connect("luanotify:event", handler)
    assert_equal(0, call_counter)
    event.emit("luanotify:event")
    assert_equal(1, call_counter)
    event.block("luanotify:event", handler)
    event.emit("luanotify:event")
    assert_equal(1, call_counter)
    event.emit("luanotify:event")
    assert_equal(1, call_counter)
end

function test_if_a_handler_doesnt_got_blocked_if_its_parent_was_blocked()
    local handler = function (name) call_counter = call_counter + 1 end

    event.connect("luanotify:event", handler)
    assert_equal(0, call_counter)
    event.emit("luanotify:event")
    assert_equal(1, call_counter)
    event.block("luanotify", handler)
    event.emit("luanotify:event")
    assert_equal(2, call_counter)
end

function test_if_you_block_a_disconnected_handler_nothing_happens()
    local handler = function (name) call_counter = call_counter + 1 end
    event.block("luanotify:event", handler)
end


function test_if_you_unblock_a_disconnected_handler_nothing_happens()
    local handler = function (name) call_counter = call_counter + 1 end
    event.unblock("luanotify:event", handler)
end


function test_a_blocked_handler_can_be_unblocked()
    local handler = function (name) call_counter = call_counter + 1 end

    event.connect("luanotify:event", handler)
    assert_equal(0, call_counter)
    event.emit("luanotify:event")
    assert_equal(1, call_counter)
    event.block("luanotify:event", handler)
    event.emit("luanotify:event")
    assert_equal(1, call_counter)
    event.unblock("luanotify:event", handler)
    event.emit("luanotify:event")
    assert_equal(2, call_counter)
end

function test_if_you_unblock_parent_events_the_handler_can_be_unblocked()
    local handler = function (name) call_counter = call_counter + 1 end

    event.connect("luanotify:event", handler)
    assert_equal(0, call_counter)
    event.emit("luanotify:event")
    assert_equal(1, call_counter)
    event.block("luanotify", handler)
    event.emit("luanotify:event")
    assert_equal(1, call_counter)
    event.unblock("luanotify", handler)
    event.emit("luanotify:event")
    assert_equal(2, call_counter)
end

function test_a_blocked_handler_must_be_unblocked_on_the_same_event_it_was_blocked_not_parent_events()
   local handler = function (name) call_counter = call_counter + 1 end

    event.connect("luanotify:event:test", handler)
    assert_equal(0, call_counter)
    event.emit("luanotify:event:test")
    assert_equal(1, call_counter)
    event.block("luanotify:event:test", handler)
    event.emit("luanotify:event:test")
    assert_equal(1, call_counter)
    event.unblock("luanotify:event", handler)
    event.emit("luanotify:event:test")
    assert_equal(1, call_counter)
    event.unblock("luanotify:event:test", handler)
    event.emit("luanotify:event:test")
    assert_equal(2, call_counter)
end


function test_a_blocked_handler_must_be_unblocked_on_the_same_event_it_was_blocked_not_child_events()
   local handler = function (name) call_counter = call_counter + 1 end

    event.connect("luanotify:event", handler)
    assert_equal(0, call_counter)
    event.emit("luanotify:event:test")
    assert_equal(1, call_counter)
    event.block("luanotify:event", handler)
    event.emit("luanotify:event:test")
    assert_equal(1, call_counter)
    event.unblock("luanotify:event:test", handler)
    event.emit("luanotify:event:test")
    assert_equal(1, call_counter)
    event.unblock("luanotify:event", handler)
    event.emit("luanotify:event:test")
    assert_equal(2, call_counter)
end


function test_a_unblocked_handler_will_be_called_on_its_original_position()
    local handler1 = function (name)
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end

    local handler2 = function (name)
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    local handler3 = function (name, offset)
                  local offset = offset or 0
                  assert_equal(2 - offset, call_counter)
                  call_counter = call_counter + 1
               end

    event.connect("luanotify", handler1)
    event.connect("luanotify", handler2)
    event.connect("luanotify", handler3)
    event.block("luanotify", handler2)
    event.emit("luanotify", 1)

    call_counter = 0
    event.unblock("luanotify", handler2)
    event.emit("luanotify")
end


function test_a_handler_must_be_unblocked_the_same_times_it_has_been_blocked()
    local handler = function (name) call_counter = call_counter + 1 end

    event.connect("luanotify", handler)
    event.block("luanotify", handler)
    event.block("luanotify", handler)
    event.block("luanotify", handler)

    event.emit("luanotify")
    assert_equal(0, call_counter)

    event.unblock("luanotify", handler)
    event.emit("luanotify")
    assert_equal(0, call_counter)

    event.unblock("luanotify", handler)
    event.emit("luanotify")
    assert_equal(0, call_counter)

    event.unblock("luanotify", handler)
    event.emit("luanotify")
    assert_equal(1, call_counter)
end


function test_a_handler_must_be_unblocked_the_same_times_and_on_the_same_event_it_has_been_blocked_not_parent_events()
    local handler = function (name) call_counter = call_counter + 1 end

    event.connect("luanotify:event", handler)
    event.block("luanotify:event", handler)
    event.block("luanotify:event", handler)

    event.emit("luanotify:event")
    assert_equal(0, call_counter)

    event.unblock("luanotify:event", handler)
    event.emit("luanotify:event")
    assert_equal(0, call_counter)

    event.unblock("luanotify", handler)
    event.emit("luanotify:event")
    assert_equal(0, call_counter)

    event.unblock("luanotify:event", handler)
    event.emit("luanotify")
    assert_equal(1, call_counter)
end


function test_a_handler_must_be_unblocked_the_same_times_and_on_the_same_event_it_has_been_blocked_not_child_events()
    local handler = function (name) call_counter = call_counter + 1 end

    event.connect("luanotify:event:test", handler)
    event.block("luanotify:event", handler)
    event.block("luanotify:event", handler)

    event.emit("luanotify:event:test")
    assert_equal(0, call_counter)

    event.unblock("luanotify:event", handler)
    event.emit("luanotify:event:test")
    assert_equal(0, call_counter)

    event.unblock("luanotify:event:test", handler)
    event.emit("luanotify:event:test")
    assert_equal(0, call_counter)

    event.unblock("luanotify:event", handler)
    event.emit("luanotify:event:test")
    assert_equal(1, call_counter)
end


function test_an_error_is_generated_if_you_add_a_pre_emit_that_is_not_a_function()
    local pre_emit = "not a function"
    assert_error("add_pre_emit: expected a function, got a "..type(pre_emit), function () event.add_pre_emit("test", pre_emit) end)
end


function test_pre_emit_functions_are_always_called_before_the_handlers_of_the_event()
    local handler1 = function (name)
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end

    local handler2 = function (name)
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    local pre_emit = function (name)
                  assert_equal(0 , call_counter)
               end

    event.connect("luanotify:event", handler1)
    event.connect("luanotify:event", handler2)
    event.add_pre_emit("luanotify:event", pre_emit)
    event.emit("luanotify:event")
end


function test_the_same_pre_emit_can_be_added_on_multiple_events()
    local pre_emit = function (name) call_counter = call_counter + 1 end

    event.add_pre_emit("luanotify:event:test1", pre_emit)
    event.add_pre_emit("luanotify:event:test2", pre_emit)

    assert_equal(0, call_counter)
    event.emit("luanotify:event:test1")
    assert_equal(1, call_counter)
    event.emit("luanotify:event:test2")
    assert_equal(2, call_counter)
end


function test_if_the_same_pre_emit_is_added_multiple_times_on_the_same_event_it_will_be_called_only_once()
    local pre_emit = function (name) call_counter = call_counter + 1 end

    event.add_pre_emit("luanotify:event:test", pre_emit)
    event.add_pre_emit("luanotify:event:test", pre_emit)
    event.add_pre_emit("luanotify:event:test", pre_emit)

    assert_equal(0, call_counter)
    event.emit("luanotify:event:test")
    assert_equal(1, call_counter)
end


function test_if_the_same_pre_emit_is_added_multiple_times_on_the_same_event_it_has_to_be_removed_only_once()
    local pre_emit = function (name) call_counter = call_counter + 1 end

    event.add_pre_emit("luanotify:event:test", pre_emit)
    event.add_pre_emit("luanotify:event:test", pre_emit)
    event.add_pre_emit("luanotify:event:test", pre_emit)

    assert_equal(0, call_counter)
    event.emit("luanotify:event:test")
    assert_equal(1, call_counter)
    event.remove_pre_emit("luanotify:event:test", pre_emit)
    event.emit("luanotify:event:test")
    assert_equal(1, call_counter)
end


function test_pre_emit_functions_are_called_on_a_queue_behavior()
    local handler  = function (name)
                  assert_equal(2, call_counter)
                  call_counter = call_counter + 1
               end

    local pre_emit1 = function (name)
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end

    local pre_emit2 = function (name)
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    event.connect("luanotify:event", handler)
    event.add_pre_emit("luanotify:event", pre_emit1)
    event.add_pre_emit("luanotify:event", pre_emit2)
    event.emit("luanotify:event")
end


function test_if_you_remove_a_pre_emit_that_is_not_connected_to_the_event_nothing_happens()
    local pre_emit   = function (name)
                  assert_equal(0, call_counter)
               end

    event.remove_pre_emit("luanotify:event", pre_emit)
end


function test_after_removing_a_pre_emit_function_the_order_of_the_remaining_pre_emits_remain_the_same()
    local pre_emit = function (name)
                         assert_equal(1, call_counter)
                         call_counter = call_counter + 1
                     end
    local handler1 = function (name)
                         assert_equal(2, call_counter)
                         call_counter = call_counter + 1
                     end
    local handler2 = function (name)
                         assert_equal(3, call_counter)
                         call_counter = call_counter + 1
                     end
    local handler3 = function (name)
                         assert_equal(4, call_counter)
                         call_counter = call_counter + 1
                     end

    event.add_pre_emit("luanotify:event:test", pre_emit)
    event.connect("luanotify:event:test", handler1)
    event.connect("luanotify:event:test", handler2)
    event.connect("luanotify:event:test", handler3)

    event.emit("luanotify:event:test")
    assert_equal(4, call_counter)
    event.remove_pre_emit("luanotify:event:test", pre_emit)
    call_counter = 0
    event.emit("luanotify:event:test")
    assert_equal(3, call_counter)
end


function test_pre_emit_functions_are_called_only_once_before_the_handlers()
    local handler1 = function (name)
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    local handler2 = function (name)
                  assert_equal(2, call_counter)
                  call_counter = call_counter + 1
               end

    local pre_emit = function (name)
                  assert_equal(0 , call_counter)
                  call_counter = call_counter + 1
               end

    event.connect("luanotify:event", handler1)
    event.connect("luanotify:event", handler2)
    event.add_pre_emit("luanotify:event", pre_emit)
    event.emit("luanotify:event")
end


function test_pre_emit_functions_are_called_only_before_the_handlers_of_the_exact_event_it_was_added_not_the_parent_events()
    local pre_emit = function (name)
                  assert_equal(0 , call_counter)
                  call_counter = call_counter + 1
               end

    event.add_pre_emit("luanotify:event", pre_emit)
    event.emit("luanotify")
    assert_equals(0, call_counter)
    event.emit("luanotify:event")
    assert_equals(1, call_counter)
end


function test_pre_emit_functions_are_called_only_before_the_handlers_of_the_exact_event_it_was_added_not_the_child_events()
    local pre_emit = function (name)
                  assert_equal(0 , call_counter)
                  call_counter = call_counter + 1
               end

    event.add_pre_emit("luanotify:event", pre_emit)
    event.emit("luanotify")
    assert_equals(0, call_counter)
    event.emit("luanotify:event")
    assert_equals(1, call_counter)
end


function test_if_you_add_a_pre_emit_on_a_event_that_does_not_have_any_connected_handlers_it_is_called()
    local pre_emit = function (name)
                  assert_equal(0 , call_counter)
                  call_counter = call_counter + 1
               end

    event.add_pre_emit("luanotify:event", pre_emit)
    event.emit("luanotify:event")
    assert_equals(1, call_counter)
end


function test_no_emission_data_is_passed_to_the_pre_emit_functions()
    local pre_emit = function (name, arg)
                         assert_equal("luanotify:event", name)
                         assert_nil(arg)
               end

    event.add_pre_emit("luanotify:event", pre_emit)
    event.emit("luanotify:event", "pineapple")
    assert_equals(1, call_counter)
end


function test_after_being_removed_a_pre_emit_function_wont_be_called_anymore()
    pre_emit1 = function (name)
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end

    pre_emit2 = function (name)
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    local offset = 0
    pre_emit3 = function (name)
                  assert_equal(2 - offset, call_counter)
                  call_counter = call_counter + 1
               end

    event.add_pre_emit("luanotify:event", pre_emit1)
    event.add_pre_emit("luanotify:event", pre_emit2)
    event.add_pre_emit("luanotify:event", pre_emit3)
    event.emit("luanotify:event")

    event.remove_pre_emit("luanotify:event", pre_emit2)
    offset = 1; call_counter = 0
    event.emit("luanotify:event")
end


function test_an_error_is_generated_if_you_add_a_post_emit_that_is_not_a_function()
    local post_emit = "not a function"
    assert_error("add_post_emit: expected a function, got a "..type(post_emit), function () event.add_post_emit(post_emit) end)
end


function test_post_emit_functions_are_called_only_after_the_handlers_of_the_exact_event_it_was_added_not_the_parent_events()
    local post_emit = function (name)
                  assert_equal(0 , call_counter)
                  call_counter = call_counter + 1
               end

    event.add_post_emit("luanotify:event", post_emit)
    event.emit("luanotify")
    assert_equals(0, call_counter)
    event.emit("luanotify:event")
    assert_equals(1, call_counter)
end


function test_post_emit_functions_are_called_only_after_the_handlers_of_the_exact_event_it_was_added_not_the_child_events()
    local post_emit = function (name)
                  assert_equal(0 , call_counter)
                  call_counter = call_counter + 1
               end

    event.add_post_emit("luanotify:event", post_emit)
    event.emit("luanotify")
    assert_equals(0, call_counter)
    event.emit("luanotify:event")
    assert_equals(1, call_counter)
end


function test_post_emit_functions_are_always_called_after_the_handlers()
    local handler1 = function (name)
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end

    local handler2 = function (name)
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    local post_emit = function (name)
                  assert_equal(2 , call_counter)
                  call_counter = call_counter + 1
                end

    event.connect("luanotify:event", handler1)
    event.connect("luanotify:event", handler2)
    event.add_post_emit("luanotify:event", post_emit)
    event.emit("luanotify:event")
    assert_equal(3, call_counter)
end


function test_the_same_post_emit_can_be_added_on_multiple_events()
    local post_emit = function (name) call_counter = call_counter + 1 end

    event.add_post_emit("luanotify:event:test1", post_emit)
    event.add_post_emit("luanotify:event:test2", post_emit)

    assert_equal(0, call_counter)
    event.emit("luanotify:event:test1")
    assert_equal(1, call_counter)
    event.emit("luanotify:event:test2")
    assert_equal(2, call_counter)
end


function test_post_emit_functions_are_called_only_once_after_the_handlers()
    local handler1 = function (name)
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end

    local handler2 = function (name)
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    local post_emit = function (name)
                  assert_equal(2 , call_counter)
                  call_counter = call_counter + 1
                end

    event.connect("luanotify:event", handler1)
    event.connect("luanotify:event", handler2)
    event.add_post_emit("luanotify:event", post_emit)
    event.emit("luanotify:event")
    assert_equal(3, call_counter)
end


function test_no_emission_data_is_passed_to_the_post_emit_functions()
    local post_emit = function (name, arg)
                         assert_equal("luanotify:event", name)
                         assert_nil(arg)
               end

    event.add_post_emit("luanotify:event", post_emit)
    event.emit("luanotify:event", "pineapple")
    assert_equals(1, call_counter)
end


function test_after_being_removed_a_post_emit_function_wont_be_called_anymore()
    local post_emit1 = function (name)
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end

    local post_emit2 = function (name)
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    local offset = 0
    local post_emit3 = function (name)
                  assert_equal(2 - offset, call_counter)
                  call_counter = call_counter + 1
               end

    event.add_post_emit("luanotify:event", post_emit1)
    event.add_post_emit("luanotify:event", post_emit2)
    event.add_post_emit("luanotify:event", post_emit3)
    event.emit("luanotify:event")

    event.remove_post_emit("luanotify:event", post_emit2)
    offset = 1; call_counter = 0
    event.emit("luanotify:event")
end


function test_if_the_same_post_emit_is_added_multiple_times_on_the_same_event_it_will_be_called_only_once()
    local post_emit = function (name)
                  call_counter = call_counter + 1
               end

    event.add_post_emit("luanotify:event", post_emit)
    event.add_post_emit("luanotify:event", post_emit)
    event.add_post_emit("luanotify:event", post_emit)
    event.emit("luanotify:event")
    assert_equal(1, call_counter)
end


function test_if_the_same_post_emit_is_added_multiple_times_on_the_same_event_it_has_to_be_removed_only_once()
    local post_emit = function (name)
                  call_counter = call_counter + 1
               end

    event.add_post_emit("luanotify:event", post_emit)
    event.add_post_emit("luanotify:event", post_emit)
    event.add_post_emit("luanotify:event", post_emit)
    event.emit("luanotify:event")
    assert_equal(1, call_counter)
    
    event.remove_post_emit("luanotify:event", post_emit)
    event.emit("luanotify:event")
    assert_equal(1, call_counter)
end


function test_post_emit_functions_are_called_on_a_stack_behavior()
    local post_emit1 = function (name)
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end

    local post_emit2 = function (name)
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    local post_emit3 = function (name)
                  assert_equal(2, call_counter)
                  call_counter = call_counter + 1
               end

    assert_equal(0, call_counter)
    event.add_post_emit("luanotify:event", post_emit3)
    event.add_post_emit("luanotify:event", post_emit2)
    event.add_post_emit("luanotify:event", post_emit1)
    event.emit("luanotify:event")
    assert_equal(3, call_counter)
end


function test_after_removing_a_post_emit_function_the_order_of_the_post_emits_remain_the_same()
    local post_emit1 = function (name)
                  assert_equal(0, call_counter)
                  call_counter = call_counter + 1
               end

    local post_emit2 = function (name)
                  assert_equal(1, call_counter)
                  call_counter = call_counter + 1
               end

    local offset = 0
    local post_emit3 = function (name)
                  assert_equal(2 - offset, call_counter)
                  call_counter = call_counter + 1
               end

    assert_equal(0, call_counter)
    event.add_post_emit("luanotify:event", post_emit3)
    event.add_post_emit("luanotify:event", post_emit2)
    event.add_post_emit("luanotify:event", post_emit1)
    event.emit("luanotify:event")
    assert_equal(3, call_counter)

    event.remove_post_emit("luanotify:event", post_emit2)
    offset = 1; call_counter = 0
    event.emit()
    assert_equal(2, call_counter)
end


function test_if_you_add_a_post_emit_on_a_event_that_does_not_have_any_connected_handlers_it_is_called()
    local post_emit  = function (name)
                           call_counter = 1
                       end

    event.add_post_emit("luanotify", post_emit)
    call_counter = 0
    event.emit("luanotify")
    assert_equal(call_counter, 1)
end


function test_if_you_remove_a_post_emit_that_has_not_been_added_nothing_happens()
    local post_emit  = function ()
                           assert_equal(0, call_counter)
                       end

    event.remove_post_emit("luanotify:event", post_emit)
end


function test_if_the_accumulator_is_not_a_function_gives_out_a_error()
    local accumulator = "not a function"
    assert_error("emit_with_accumulator: expected a function, got a "..type(accumulator), function () event.emit_with_accumulator("luanotify", accum) end)
end


function test_the_return_value_of_each_handler_is_passed_to_the_accumulator()
    local handler1 = function (name)
                         assert_equal(0, call_counter)
                         call_counter = call_counter + 1
                         return call_counter
                     end

    local handler2 = function (name)
                         assert_equal(1, call_counter)
                         call_counter = call_counter + 1
                         return call_counter
                     end

    local counter = 0

    local accumulator = function (name, arg1)
                            counter = counter + arg1
                        end

    event.connect("luanotify:event", handler1)
    event.connect("luanotify:event", handler2)
    event.emit_with_accumulator("luanotify:event", accumulator)
    assert_equal(2, call_counter)
    assert_equal(3, counter)
end


function test_the_return_value_of_each_handler_on_all_the_events_on_the_branch_of_the_emitted_event_are_passed_to_the_accumulator()
    local handler1 = function (name)
                         assert_equal(0, call_counter)
                         call_counter = call_counter + 1
                         return call_counter
                     end

    local handler2 = function (name)
                         assert_equal(1, call_counter)
                         call_counter = call_counter + 1
                         return call_counter
                     end

    local counter = 0

    local accumulator = function (name, arg1)
                            assert_equal("luanotify:event", name)
                            counter = counter + arg1
                        end

    event.connect("luanotify", handler1)
    event.connect("luanotify:event", handler2)
    event.emit_with_accumulator("luanotify:event", accumulator)
    assert_equal(2, call_counter)
    assert_equal(3, counter)
end


function test_after_the_execution_of_each_handler_the_accumulator_is_called()
    local handler1 = function (name)
                         call_counter = call_counter + 1
                     end

    local handler2 = function (name)
                         call_counter = call_counter + 1
                     end

    local counter = 0

    local accumulator = function (name)
                            counter = counter + 1
                            assert_equal(call_counter, counter)
                        end

    event.connect("luanotify:event", handler1)
    event.connect("luanotify:event", handler2)
    event.emit_with_accumulator("luanotify:event", accumulator)
end


function test_even_when_the_handler_returns_nil_it_is_repassed_to_the_accumulator()
    local handler = function ()
                    end

    local accumulator = function (name, arg)
                            assert_nil(arg)
                        end

    event.connect("luanotify:event", handler)
    event.emit_with_accumulator("luanotify:event", accumulator)
end


function test_the_handlers_can_return_multiple_values_to_the_accumulator()
    local handler = function (name)
                        return 1, 2
                    end

    local accumulator = function (name, arg1, arg2)
                            assert_equal(arg1, 1)
                            assert_equal(arg1, 2)
                        end

    event.connect("luanotify:event", handler)
    event.emit_with_accumulator("luanotify:event", accumulator)
end


function test_pre_emit_functions_return_values_are_not_passed_to_the_accumulator()
    local pre_emit = function (name)
                       return 1
                   end

    local handler = function (name)
                       return 2
                    end

    local accumulator = function (name, arg)
                            assert_equal(arg, 2)
                        end

    event.add_pre_emit("luanotify:event", pre_emit)
    event.connect("luanotify:event", handler)
    event.emit_with_accumulator("luanotify:event", accumulator)
end


function test_post_emit_functions_return_values_are_not_passed_to_the_accumulator()
    local post_emit = function (name)
                       return 1
                   end

    local handler = function (name)
                       return 2
                    end

    local accumulator = function (name, arg)
                            assert_equal(arg, 2)
                        end

    event.add_post_emit("luanotify:event", post_emit)
    event.connect("luanotify:event", handler)
    event.emit_with_accumulator("luanotify:event", accumulator)
end


function test_after_a_stop_no_more_handlers_are_called_on_that_emission()
    local handler1 = function (name)
                         assert_equal(0, call_counter)
                         call_counter = call_counter + 1
                     end

    local handler2 = function (name)
                         assert_equal(1, call_counter)
                         call_counter = call_counter + 1
                         event.stop("luanotify:event")
                     end

    local handler3 = function (name)
                         call_counter = call_counter + 1
                     end

    event.connect("luanotify:event", handler1)
    event.connect("luanotify:event", handler2)
    event.connect("luanotify:event", handler3)

    assert_equal(0, call_counter)
    event.emit("luanotify:event")
    assert_equal(2, call_counter)
end


function test_emission_can_be_stopped_inside_a_handler()
    local handler1 = function (name)
                         assert_equal(0, call_counter)
                         call_counter = call_counter + 1
                         event.stop("luanotify:event")
                     end

    local handler2 = function (name)
                         assert_equal(1, call_counter)
                         call_counter = call_counter + 1
                     end

    event.connect("luanotify:event", handler1)
    event.connect("luanotify:event", handler2)

    event.emit("luanotify:event")
    assert_equal(1, call_counter)
end


function test_emission_can_be_stopped_inside_any_handler_on_the_emitted_event_branch()
    local handler1 = function (name)
                         assert_equal(0, call_counter)
                         call_counter = call_counter + 1
                         event.stop("luanotify:event")
                     end

    local handler2 = function (name)
                         assert_equal(1, call_counter)
                         call_counter = call_counter + 1
                     end

    event.connect("luanotify", handler1)
    event.connect("luanotify:event", handler2)

    event.emit("luanotify:event")
    assert_equal(1, call_counter)
end


function test_emission_can_be_stopped_inside_a_pre_emit()
    local pre_emit = function (name)
                         assert_equal(0, call_counter)
                         call_counter = call_counter + 1
                         event.stop("luanotify:event")
                     end

    local handler2 = function (name)
                         assert_equal(1, call_counter)
                         call_counter = call_counter + 1
                     end

    event.add_pre_emit("luanotify", handler1)
    event.connect("luanotify:event", handler2)

    event.emit("luanotify:event")
    assert_equal(1, call_counter)
end


function test_emission_can_be_stopped_inside_a_accumulator()
    local handler1 = function (name)
                        assert_equal(0, call_counter)
                        call_counter = call_counter + 1
                     end

    local handler2 = function (name)
                        assert_equal(1, call_counter)
                        call_counter = call_counter + 1
                     end

    local accumulator = function (name)
                            event.stop()
                        end

    event.connect("luanotify:event", handler1)
    event.connect("luanotify:event", handler2)
    event.emit_with_accumulator("luanotify:event", accumulator)
    assert_equal(1, call_counter)
end


function test_stopping_will_not_stop_the_pre_emit_functions()
    local pre_emit1 = function (name)
                        assert_equal(0, call_counter)
                        call_counter = call_counter + 1
                        event.stop("luanotify:event")
                    end

    local pre_emit2 = function (name)
                        assert_equal(1, call_counter)
                        call_counter = call_counter + 1
                    end

    local handler = function (name)
                        assert_equal(2, call_counter)
                        call_counter = call_counter + 1
                    end

    event.add_pre_emit("luanotify:event", pre_emit1)
    event.add_pre_emit("luanotify:event", pre_emit2)
    event.connect("luanotify:event", handler)
    event.emit("luanotify:event")
    assert_equal(2, call_counter)
end


function test_stopping_will_not_stop_the_post_emit_functions()
    local post_emit = function (name)
                          assert_equal(1, call_counter)
                          call_counter = call_counter + 1
                      end

    local handler1 = function (name)
                         assert_equal(0, call_counter)
                         call_counter = call_counter + 1
                         event.stop("luanotify:event")
                     end

    local handler2 = function (name)
                         assert_equal(1, call_counter)
                         call_counter = call_counter + 1
                     end

    event.add_post_emit("luanotify:event", post_emit)
    event.connect("luanotify:event", handler1)
    event.connect("luanotify:event", handler2)
    event.emit("luanotify:event")
    assert_equal(2, call_counter)
end


function test_when_emitting_a_subevent_all_handlers_connected_to_the_subevent_branch_are_called()
    local handler = function (name) call_counter = call_counter + 1 end

    event.connect("luanotify", handler)
    event.connect("luanotify:event", handler)
    event.connect("luanotify:event:test", handler)
    assert_equal(0, call_counter)
    event.emit("luanotify:event:test")
    assert_equal(3, call_counter)
end


function test_on_a_subevent_emission_the_handlers_on_the_subevent_branch_are_called_from_the_top_to_the_bottom()
    local handler1 = function (name)
                         assert_equal(0, call_counter)
                         call_counter = call_counter + 1
                     end

    local handler2 = function (name)
                         assert_equal(1, call_counter)
                         call_counter = call_counter + 1
                     end

    event.connect("luanotify", handler1)
    event.connect("luanotify:event", handler2)
    event.emit("luanotify:event")
    assert_equal(2, call_counter)
end


function test_on_a_subevent_emission_only_handlers_from_the_parents_are_called_not_from_child_events()
    local handler = function (name) call_counter = call_counter + 1 end

    event.connect("luanotify", handler)
    event.connect("luanotify:event", handler)
    event.connect("luanotify:event:test", handler)
    assert_equal(0, call_counter)
    event.emit("luanotify:event")
    assert_equal(2, call_counter)
end


lunit.main()
