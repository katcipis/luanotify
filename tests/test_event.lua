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
end

function tearDown()
end


function test_if_a_handler_function_is_connected_to_a_event_it_will_always_be_called_when_that_event_emission_occurs()
end


function test_an_error_is_generated_if_you_connect_a_handler_that_is_not_a_function()
    assert_error("connect: expected a function, got a "..type(handler), function () event.connect("test", handler) end)
end


function test_if_there_is_no_handler_connected_to_an_event_the_emission_of_the_event_does_nothing()
end


function test_handlers_connected_to_a_event_are_called_on_a_queue_behavior()
end


function test_handlers_receive_all_the_data_that_is_passed_on_emission()
end


function test_the_first_parameter_given_to_a_handler_on_emission_is_always_the_name_of_the_emitted_event()
end


function test_all_event_handlers_on_the_event_tree_receive_the_name_of_the_emitted_event_as_the_first_parameter()
end


function test_handlers_receive_all_the_data_that_is_passed_on_emission_on_the_order_it_was_on_emission_call()
end


function test_if_the_same_handler_is_connected_multiple_times_to_the_same_event_it_will_be_called_only_once()
end


function test_the_same_handler_function_can_be_connected_to_different_events()
end


function test_if_the_same_handler_is_connected_multiple_times_to_the_same_event_it_has_to_be_disconnected_only_once()
end


function test_if_you_disconnect_a_handler_from_a_event_that_it_is_not_connected_nothing_happens()
end


function test_if_a_handler_is_disconnected_from_a_event_the_calling_order_of_the_remaining_handlers_wont_change()
end


function test_if_a_handler_is_disconnected_from_a_event_it_will_not_be_called_anymore_when_that_event_emits()
end


function test_the_handler_function_must_be_disconnected_from_the_exact_same_event_it_was_connected_not_parent_events()
end


function test_the_handler_function_must_be_disconnected_from_the_exact_same_event_it_was_connected_not_child_events()
end


function test_if_a_handler_got_blocked_it_wont_be_called_on_emission()
end


function test_if_you_block_a_disconnected_handler_nothing_happens()
end


function test_if_you_unblock_a_disconnected_handler_nothing_happens()
end


function test_a_blocked_handler_can_be_unblocked()
end


function test_a_blocked_handler_must_be_unblocked_on_the_same_event_it_was_blocked_not_parent_events()
end


function test_a_blocked_handler_must_be_unblocked_on_the_same_event_it_was_blocked_not_child_events()
end


function test_a_unblocked_handler_will_be_called_on_its_original_position()
end


function test_a_handler_must_be_unblocked_the_same_times_it_has_been_blocked()
end


function test_a_handler_must_be_unblocked_the_same_times_and_on_the_same_event_it_has_been_blocked_not_parent_events()
end


function test_a_handler_must_be_unblocked_the_same_times_and_on_the_same_event_it_has_been_blocked_not_child_events()
end


function test_an_error_is_generated_if_you_add_a_pre_emit_that_is_not_a_function()
    local pre_emit = "not a function"
    assert_error("add_pre_emit: expected a function, got a "..type(pre_emit), function () event.add_pre_emit("test", pre_emit) end)
end


function test_pre_emit_functions_are_always_called_before_the_handlers_of_the_event()
end


function test_the_same_pre_emit_can_be_added_on_multiple_events()
end


function test_if_the_same_pre_emit_is_added_multiple_times_on_the_same_event_it_will_be_called_only_once()
end


function test_if_the_same_pre_emit_is_added_multiple_times_on_the_same_event_it_has_to_be_removed_only_once()
end


function test_pre_emit_functions_are_called_on_a_queue_behavior()
end


function test_if_you_remove_a_pre_emit_that_is_not_connected_to_the_event_nothing_happens()
end


function test_after_removing_a_pre_emit_function_the_order_of_the_remaining_pre_emits_remain_the_same()
end


function test_pre_emit_functions_are_called_only_once_before_the_handlers()
end


function test_pre_emit_functions_are_called_only_before_the_handlers_of_the_exact_event_it_was_added_not_the_parent_events()
end


function test_pre_emit_functions_are_called_only_before_the_handlers_of_the_exact_event_it_was_added_not_the_child_events()
end


function test_no_emission_data_is_passed_to_the_pre_emit_functions()
end


function test_after_being_removed_a_pre_emit_function_wont_be_called_anymore()
end


function test_an_error_is_generated_if_you_add_a_post_emit_that_is_not_a_function()
    local post_emit = "not a function"
    assert_error("add_post_emit: expected a function, got a "..type(post_emit), function () signal:add_post_emit(post_emit) end)
end


function test_post_emit_functions_are_called_only_after_the_handlers_of_the_exact_event_it_was_added_not_the_parent_events()
end


function test_post_emit_functions_are_called_only_after_the_handlers_of_the_exact_event_it_was_added_not_the_child_events()
end


function test_post_emit_functions_are_always_called_after_the_handlers()
end


function test_the_same_post_emit_can_be_added_on_multiple_events()
end


function test_post_emit_functions_are_called_only_once_after_the_handlers()
end


function test_no_emission_data_is_passed_to_the_post_emit_functions()
end


function test_after_being_removed_a_post_emit_function_wont_be_called_anymore()
end


function test_if_the_same_post_emit_is_added_multiple_times_on_the_same_event_it_will_be_called_only_once()
end


function test_if_the_same_post_emit_is_added_multiple_times_on_the_same_event_it_has_to_be_removed_only_once()
end


function test_post_emit_functions_are_called_on_a_stack_behavior()
end


function test_after_removing_a_post_emit_function_the_order_of_the_post_emits_remain_the_same()
end


function test_if_you_remove_a_post_emit_that_does_not_exist_nothing_happens()
    post_emit  = function ()
                  assert_equal(0, call_counter)
               end

    event.remove_post_emit("test", post_emit)
end


function test_if_the_accumulator_is_not_a_function_gives_out_a_error()
end


function test_the_return_value_of_each_handler_is_passed_to_the_accumulator()
end


function test_the_return_value_of_each_handler_on_all_the_events_on_the_branch_of_the_emitted_event_are_passed_to_the_accumulator()
end


function test_after_the_execution_of_each_handler_the_accumulator_is_called()
end


function test_even_when_the_handler_returns_nil_it_is_repassed_to_the_accumulator()
end


function test_the_handlers_can_return_multiple_values_to_the_accumulator()
end


function test_pre_emit_functions_return_values_are_not_passed_to_the_accumulator()
end


function test_post_emit_functions_return_values_are_not_passed_to_the_accumulator()
end


function test_after_a_stop_no_more_handlers_are_called_on_that_emission()
end


function test_emission_can_be_stopped_inside_a_handler()
end


function test_emission_can_be_stopped_inside_any_handler_on_the_emitted_event_branch()
end


function test_emission_can_be_stopped_inside_a_pre_emit()
end


function test_emission_can_be_stopped_inside_a_accumulator()
end


function test_stopping_will_not_stop_the_pre_emit_functions()
end


function test_stopping_will_not_stop_the_post_emit_functions()
end


function test_when_emitting_a_subevent_all_handlers_connected_to_the_subevent_branch_are_called()
end


function test_on_a_subevent_emission_the_handlers_on_the_subevent_branch_are_called_from_the_top_to_the_bottom()
end


function test_on_a_subevent_emission_only_handlers_from_the_parents_are_called_not_from_child_events()
end


lunit.main()
