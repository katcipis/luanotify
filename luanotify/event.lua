---------------------------------------------------------------------------------
-- Copyright (C) 2010 Tiago Katcipis <tiagokatcipis@gmail.com>
-- Copyright (C) 2010 Paulo Pizarro  <paulo.pizarro@gmail.com>
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
-- along with LuaNotify.  If not, see <http://www.gnu.org/licenses/>.
---------------------------------------------------------------------------------
module(..., package.seeall)

local signal = require "luanotify.signal"

---------------------------------------
-- Internal data (registered events) --
---------------------------------------
local events = {}

---------------------------------
-- Private functions definition --
---------------------------------
local function get_nodes(event_name)
    local nodes = {}
    for n in string.gmatch(event_name, "[^:]+") do
    --for n in string.gmatch(event_name, "[%w]-::[%w]-") do
        print(n)
        nodes[#nodes + 1] = n
    end
    return unpack(nodes)
end

---------------------------------
-- Public functions definition --
---------------------------------

function connect(event_name, handler_function)
    get_nodes(event_name)
end

function disconnect(event_name, handler_function)

end

function block(event_name, handler_function)

end

function unblock(event_name, handler_function)

end

function emit(event_name, ...)

end

function emit_with_accumulato_(event_name, accumulator, ...)

end

function add_pre_emit(event_name, pre_emit_func)

end

function remove_pre_emit(event_name, pre_emit_func)

end

function add_post_emit(event_name, post_emit_func)

end

function remove_post_emit(event_name, post_emit_func)

end

function stop()

end

