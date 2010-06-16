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
-- You should have received a copy of the GNU Lesser General Public License
-- along with LuaNotify.  If not, see <http://www.gnu.org/licenses/>.
---------------------------------------------------------------------------------
require "lunit"
require "notify.ordered_set"

module("ordered_set_testcase", lunit.testcase, package.seeall)


function setUp()
    ordered_set = notify.ordered_set.new()
end

function tearDown()
    ordered_set = nil
end

function test_data_pushed_on_the_back_will_be_the_last_to_access_on_iteration()
    ordered_set:push_back(1)
    ordered_set:push_back(2)
    ordered_set:push_back(3)

    local counter = 1
    assert_false(ordered_set:is_empty())

    for data in ordered_set:get_iterator() do
        assert_equal(counter, data)
        counter = counter + 1
    end
end

function test_knows_if_it_is_empty()
    assert_true(ordered_set:is_empty())
end

function test_knows_if_it_is_not_empty()
    ordered_set:push_back(1)
    assert_false(ordered_set:is_empty())
end

function test_iteration_wont_change_the_order_of_the_data()
    ordered_set:push_back(1)
    ordered_set:push_back(2)
    ordered_set:push_back(3)

    local counter = 1
    for data in ordered_set:get_iterator() do
        assert_equal(counter, data)
        counter = counter + 1
    end

    counter = 1
    for data in ordered_set:get_iterator() do
        assert_equal(counter, data)
        counter = counter + 1
    end

end

function test_if_nil_is_pushed_on_the_front_an_error_occur()
    assert_error("table index is nil", function () ordered_set:push_front(nil) end)
end

function test_if_nil_is_pushed_on_the_back_an_error_occur()
    assert_error("table index is nil", function () ordered_set:push_back(nil) end)
end

function test_data_pushed_on_the_front_will_be_the_first_to_access_on_iteration()
    ordered_set:push_front(1)
    ordered_set:push_front(2)
    ordered_set:push_front(3)

    local counter = 3
    assert_false(ordered_set:is_empty())

    for data in ordered_set:get_iterator() do
        assert_equal(counter, data)
        counter = counter - 1
    end

end

function test_after_removing_data_the_data_will_no_longer_exist_on_the_set()
    ordered_set:push_front("apple")
    ordered_set:push_front("test")
    ordered_set:push_front("pineapple")
    ordered_set:push_front("end")

    assert_false(ordered_set:is_empty())
    
    local counter = 0
    ordered_set:remove("test")
    for data in ordered_set:get_iterator() do
        assert_not_equal("test", data)
        counter = counter + 1
    end
    assert_equal(3, counter)    
    
    counter = 0
    ordered_set:remove("end")
    for data in ordered_set:get_iterator() do
        assert_not_equal("test", data)
        assert_not_equal("end", data)
        counter = counter + 1
    end
    assert_equal(2, counter)
end

function test_after_removing_data_from_the_middle_the_previous_order_remains_the_same()
    ordered_set:push_back("apple")
    ordered_set:push_back("test")
    ordered_set:push_back("pineapple")
    ordered_set:push_back("end")

    assert_false(ordered_set:is_empty())
    
    local counter = 0
    ordered_set:remove("pineapple")
    for data in ordered_set:get_iterator() do
        counter = counter + 1
        if(counter == 1) then
            assert_equal("apple", data)
        elseif(counter == 2) then
            assert_equal("test", data)
        else
            assert_equal("end", data)
        end
    end
    assert_equal(3, counter)
end

function test_after_removing_data_from_the_front_the_previous_order_remains_the_same()
    ordered_set:push_back("apple")
    ordered_set:push_back("test")
    ordered_set:push_back("pineapple")
    ordered_set:push_back("end")

    assert_false(ordered_set:is_empty())

    local counter = 0
    ordered_set:remove("apple")
    for data in ordered_set:get_iterator() do
        counter = counter + 1
        if(counter == 1) then
            assert_equal("test", data)
        elseif(counter == 2) then
            assert_equal("pineapple", data)
        else
            assert_equal("end", data)
        end
    end
    assert_equal(3, counter)
end

function test_after_removing_data_from_the_back_the_previous_order_remains_the_same()
    ordered_set:push_back("apple")
    ordered_set:push_back("test")
    ordered_set:push_back("pineapple")
    ordered_set:push_back("end")

    assert_false(ordered_set:is_empty())

    local counter = 0
    ordered_set:remove("end")
    for data in ordered_set:get_iterator() do
        counter = counter + 1
        if(counter == 1) then
            assert_equal("apple", data)
        elseif(counter == 2) then
            assert_equal("test", data)
        else
            assert_equal("pineapple", data)
        end
    end
    assert_equal(3, counter)
end

function test_after_removing_all_data_it_gets_empty()
    ordered_set:push_back("apple")
    ordered_set:push_back("test")
    ordered_set:push_back("pineapple")
    ordered_set:push_back("end")

    assert_false(ordered_set:is_empty())

    ordered_set:remove("apple")
    ordered_set:remove("test")
    ordered_set:remove("pineapple")
    ordered_set:remove("end")
   
    assert_true(ordered_set:is_empty())
    local counter = 0
    for data in ordered_set:get_iterator() do
        counter = counter + 1
    end
    assert_equal(0, counter)
end

function test_if_some_data_is_pushed_twice_it_will_be_inserted_only_once()
    ordered_set:push_back("apple")
    ordered_set:push_back("apple")
    local counter = 0
    for data in ordered_set:get_iterator() do
        counter = counter + 1
    end
    assert_equal(1, counter)
end

function test_if_some_data_is_pushed_twice_the_position_of_the_first_push_remains()
    ordered_set:push_back("apple")
    ordered_set:push_back("test")
    ordered_set:push_back("pineapple")
    ordered_set:push_back("apple")

    assert_false(ordered_set:is_empty())

    local counter = 0
    for data in ordered_set:get_iterator() do
        counter = counter + 1
        if(counter == 1) then
            assert_equal("apple", data)
        elseif(counter == 2) then
            assert_equal("test", data)
        else
            assert_equal("pineapple", data)
        end
    end
    assert_equal(3, counter)
end

function test_iteration_occurs_according_to_the_order_elements_where_inserted()
    ordered_set:push_back(3)
    ordered_set:push_back(4)
    ordered_set:push_back(5)
    ordered_set:push_front(2)
    ordered_set:push_front(1)

    local counter = 1
    for data in ordered_set:get_iterator() do
        assert_equal(counter, data)
        counter = counter + 1
    end
end

function test_all_data_pushed_is_acessed_on_iteration()
    ordered_set:push_back("apple")
    ordered_set:push_back("coconut")
    ordered_set:push_back("pineapple")

    assert_false(ordered_set:is_empty())

    local counter = 0
    for data in ordered_set:get_iterator() do
        counter = counter + 1
        if(counter == 1) then
            assert_equal("apple", data)
        elseif(counter == 2) then
            assert_equal("coconut", data)
        else
            assert_equal("pineapple", data)
        end
    end
    assert_equal(3, counter)
end

function test_if_you_remove_the_same_data_twice_nothing_happens()
    ordered_set:push_back("apple")
    assert_false(ordered_set:is_empty())
    ordered_set:remove("apple")
    assert_true(ordered_set:is_empty())
    ordered_set:remove("apple")
    assert_true(ordered_set:is_empty())
end

function test_if_you_remove_data_not_inserted_on_the_set_nothing_happens()
    ordered_set:push_back("apple")
    assert_false(ordered_set:is_empty())
    ordered_set:remove("coconut")
    assert_false(ordered_set:is_empty())
    ordered_set:remove("apple")
    assert_true(ordered_set:is_empty())
end

function test_if_you_remove_nil_nothing_happens()
    ordered_set:push_back("apple")
    assert_false(ordered_set:is_empty())
    ordered_set:remove(nil)
    assert_false(ordered_set:is_empty())
end

function test_if_you_remove_data_from_the_middle_and_insert_it_on_the_front_it_stays_on_the_front()
    ordered_set:push_back("apple")
    ordered_set:push_back("coconut")
    ordered_set:push_back("pineapple")

    ordered_set:remove("coconut")
    ordered_set:push_front("coconut")

    local counter = 0
    for data in ordered_set:get_iterator() do
        counter = counter + 1
        if(counter == 1) then
            assert_equal("coconut", data)
        elseif(counter == 2) then
            assert_equal("apple", data)
        else
            assert_equal("pineapple", data)
        end
    end
    assert_equal(3, counter)
end

function test_if_you_remove_data_from_the_middle_and_insert_it_on_the_back_it_stays_on_the_back()
    ordered_set:push_back("apple")
    ordered_set:push_back("coconut")
    ordered_set:push_back("pineapple")

    ordered_set:remove("coconut")
    ordered_set:push_back("coconut")

    local counter = 0
    for data in ordered_set:get_iterator() do
        counter = counter + 1
        if(counter == 1) then
            assert_equal("apple", data)
        elseif(counter == 2) then
            assert_equal("pineapple", data)
        else
            assert_equal("coconut", data)
        end
    end
    assert_equal(3, counter)
end

function test_if_you_remove_data_from_the_front_and_insert_it_on_the_front_it_stays_on_the_front()
    ordered_set:push_back("apple")
    ordered_set:push_back("coconut")
    ordered_set:push_back("pineapple")

    ordered_set:remove("apple")
    ordered_set:push_front("apple")

    local counter = 0
    for data in ordered_set:get_iterator() do
        counter = counter + 1
        if(counter == 1) then
            assert_equal("apple", data)
        elseif(counter == 2) then
            assert_equal("coconut", data)
        else
            assert_equal("pineapple", data)
        end
    end
    assert_equal(3, counter)
end

function test_if_you_remove_data_from_the_front_and_insert_it_on_the_back_it_stays_on_the_back()
    ordered_set:push_back("apple")
    ordered_set:push_back("coconut")
    ordered_set:push_back("pineapple")

    ordered_set:remove("apple")
    ordered_set:push_back("apple")

    local counter = 0
    for data in ordered_set:get_iterator() do
        counter = counter + 1
        if(counter == 1) then
            assert_equal("coconut", data)
        elseif(counter == 2) then
            assert_equal("pineapple", data)
        else
            assert_equal("apple", data)
        end
    end
    assert_equal(3, counter)
end

function test_if_you_remove_data_from_the_back_and_insert_it_on_the_front_it_stays_on_the_front()
    ordered_set:push_back("apple")
    ordered_set:push_back("coconut")
    ordered_set:push_back("pineapple")

    ordered_set:remove("pineapple")
    ordered_set:push_front("pineapple")

    local counter = 0
    for data in ordered_set:get_iterator() do
        counter = counter + 1
        if(counter == 1) then
            assert_equal("pineapple", data)
        elseif(counter == 2) then
            assert_equal("apple", data)
        else
            assert_equal("coconut", data)
        end
    end
    assert_equal(3, counter)
end

function test_if_you_remove_data_from_the_back_and_insert_it_on_the_back_it_stays_on_the_back()
    ordered_set:push_back("apple")
    ordered_set:push_back("coconut")
    ordered_set:push_back("pineapple")

    ordered_set:remove("pineapple")
    ordered_set:push_back("pineapple")

    local counter = 0
    for data in ordered_set:get_iterator() do
        counter = counter + 1
        if(counter == 1) then
            assert_equal("apple", data)
        elseif(counter == 2) then
            assert_equal("coconut", data)
        else
            assert_equal("pineapple", data)
        end
    end
    assert_equal(3, counter)
end

function test_after_it_gets_empty_it_can_be_used_again()
    ordered_set:push_back(1)
    ordered_set:push_back(2)
    ordered_set:push_back(3)

    local counter = 1
    for data in ordered_set:get_iterator() do
        assert_equal(counter, data)
        counter = counter + 1
    end
    ordered_set:remove(2)
    ordered_set:remove(1)
    ordered_set:remove(3)

    assert_true(ordered_set:is_empty())

    ordered_set:push_front(1)
    ordered_set:push_front(2)
    ordered_set:push_front(3)

    assert_false(ordered_set:is_empty())

    counter = 3
    for data in ordered_set:get_iterator() do
        assert_equal(counter, data)
        counter = counter - 1
    end
end

lunit.main()
