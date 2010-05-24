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

local signal    = require "luanotify.signal"
local separator = ":"

---------------------------------------
-- Internal data (registered events) --
---------------------------------------
local events = {}

---------------------------------
-- Private functions definition --
---------------------------------
local function new_node()
    return { handlers   = signal.new(),
             pre_emits  = signal.new(),
             post_emits = signal.new(), 
             subevents  = {} } 
end


local function get_nodes_names(event_name)
    local nodes_names = {}
    for n in string.gmatch(event_name, "[^"..separator.."]+") do
        nodes_names[#nodes_names + 1] = n
    end
    return nodes_names
end


local function get_node(event_name)
    local events_names = get_nodes_names(event_name)
    local current_node = events[events_names[1]] or new_node()

    events[events_names[1]] = current_node
    for i=2, #events_names do
        sub_node = current_node.subevents[events_names[i]] or new_node()
        current_node.subevents[events_names[i]] = sub_node
        current_node = sub_node
    end
    return current_node
end


local function unused_event(event_name)
    local events_names = get_nodes_names(event_name)
    local current_node = events[events_names[1]] 

    if not current_node then return true end

    for i=2, #events_names do
        sub_node = current_node.subevents[events_names[i]] 
        if not sub_node then return true end
        current_node = sub_node
    end

    return false
end

local function event_iterator(event_name)
    local events_names = get_nodes_names(event_name)
    local i = 2
    local current_node = events[events_names[1]]

    local function iterator() 
        if not current_node then return end
        local ret = current_node

        if events_names[i] then
            current_node = current_node.subevents[events_names[i]]
            i = i + 1
        else
            current_node = nil
        end
        
        return ret
    end

    return iterator
end

---------------------------------
-- Public functions definition --
---------------------------------

function connect(event_name, handler_function)
    get_node(event_name).handlers:connect(handler_function)
end

function disconnect(event_name, handler_function)
    if unused_event(event_name) then return end
    get_node(event_name).handlers:disconnect(handler_function)
end

function block(event_name, handler_function)
    if unused_event(event_name) then return end
    get_node(event_name).handlers:block(handler_function)
end

function unblock(event_name, handler_function)
    if unused_event(event_name) then return end
    get_node(event_name).handlers:unblock(handler_function)
end

function emit(event_name, ...)
    for node in event_iterator(event_name) do
        node.pre_emits:emit(event_name,...)
        node.handlers:emit(event_name,...)
        node.post_emits:emit(event_name,...)
    end
end

function emit_with_accumulator(event_name, accumulator, ...)
    for node in event_iterator(event_name) do
        node.pre_emits:emit_with_accumulator(accumulator, event_name, ...)
        node.handlers:emit_with_accumulator(accumulator, event_name, ...)
        node.post_emits:emit_with_accumulator(accumulator, event_name, ...)
    end
end

function add_pre_emit(event_name, pre_emit_func)
    get_node(event_name).pre_emits:add_pre_emit(pre_emit_func)
end

function remove_pre_emit(event_name, pre_emit_func)
    if unused_event(event_name) then return end
    local node = get_node(event_name)
    node.pre_emits:remove_pre_emit(pre_emit_func)    
end

function add_post_emit(event_name, post_emit_func)
    get_node(event_name).post_emits:add_post_emit(post_emit_func)
end

function remove_post_emit(event_name, post_emit_func)
    if unused_event(event_name) then return end
    local node = get_node(event_name)
    node.post_emits:remove_post_emit(post_emit_func)
end

function stop()

end

function clear(event_name)
    events = {} 
end
