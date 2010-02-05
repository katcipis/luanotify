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
-- along with Luasofia.  If not, see <http://www.gnu.org/licenses/>.
---------------------------------------------------------------------------------

require "lunit"
require "luanotify.ordered_set"

module("ordered_set_testcase", lunit.testcase, package.seeall)

function setUp()
    ordered_set = luanotify.ordered_set.new()
end

function tearDown()
    ordered_set = nil
end

function test_data_pushed_on_the_end_will_be_the_last_to_access_on_iteration()
end

function test_data_pushed_on_the_front_will_be_the_first_to_access_on_iteration()
end

function test_after_removing_data_the_data_will_no_longer_exist_on_the_set()
end

function test_after_removing_data_from_the_middle_the_previous_order_remains_the_same()
end

function test_after_removing_data_from_front_the_previous_order_remains_the_same()
end

function test_after_removing_data_from_the_back_the_previous_order_remains_the_same()
end

function test_iteration_occurs_according_to_the_order_elements_where_inserted()
end

lunit.main()
