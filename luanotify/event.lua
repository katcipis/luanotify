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

local set = require "luanotify.ordered_set" 

local separator = ":"
local stopped   = false

---------------------------------------
-- Internal data (registered events) --
---------------------------------------
local events = {}

---------------------------------
-- Private functions definition --
---------------------------------
local function new_node()
    return { handlers   = set.new(),
             pre_emits  = set.new(),
             post_emits = set.new(),
             blocked_handlers = {}, 
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

local function call_pre_emits(event_name)
    local nodes = set.new()
    local rev_nodes = set.new()

    for node in event_iterator(event_name) do
        for pre_emit in node.pre_emits:get_iterator() do pre_emit(event_name) end
        nodes:push_back(node)
        rev_nodes:push_front(node)
    end

    return nodes, rev_nodes
end

local function call_post_emits(event_name, rev_nodes)
    for node in rev_nodes:get_iterator() do
        for post_emit in node.post_emits:get_iterator() do post_emit(event_name) end
    end
end

local function call_handlers(params)

    for node in params.nodes:get_iterator() do
        for handler in node.handlers:get_iterator() do
            if(stopped) then return end
            if(node.blocked_handlers[handler] == 0) then
                if(params.accumulator) then
                    params.accumulator(handler(event_name, unpack(params.args)))
                else
                    handler(event_name, unpack(params.args))
                end
            end
        end
    end
end


---------------------------------
-- Public functions definition --
---------------------------------

function connect(event_name, handler_function)
    if (type(handler_function) ~= "function") then
        error("connect: expected a function, got a "..type(handler_function));
    end

    local node = get_node(event_name)
    node.handlers:push_back(handler_function)

    if not node.blocked_handlers then
        node.blocked_handlers[handler_function] = 0
    end
end

function disconnect(event_name, handler_function)
    if unused_event(event_name) then return end

    local node = get_node(event_name)
    node.handlers:remove(handler_function)
    node.blocked_handlers[handler_function] = nil
end

function block(event_name, handler_function)
    if unused_event(event_name) then return end
    local node = get_node(event_name)
    local block = node.blocked_handlers[handler_function]
    if block then
        node.blocked_handlers[handler_function] = block + 1
    end
end

function unblock(event_name, handler_function)
    if unused_event(event_name) then return end
    local node = get_node(event_name)
    if node.blocked_handlers[handler_function] and 
       node.blocked_handlers[handler_function] > 0 then

        node.blocked_handlers[handler_function] = node.blocked_handlers[handler_function] - 1
    end
end

function emit(event_name, ...)
    stopped = false
    local nodes, rev_nodes = call_pre_emits(event_name)
    call_handlers{event_name=event_name, nodes=nodes, args={...}}
    call_post_emits(event_name, rev_nodes)
end

function emit_with_accumulator(event_name, accumulator, ...)
    if (type(accumulator) ~= "function") then
        error("emit_with_accumulator: expected a function, got a "..type(accumulator));
    end
    stopped = false
    local nodes, rev_nodes = call_pre_emits(event_name)
    call_handlers{event_name=event_name, nodes=nodes, accumulator=accumulator, args={...}}
    call_post_emits(event_name, rev_nodes)
end

function add_pre_emit(event_name, pre_emit_func)
    if (type(pre_emit_func) ~= "function") then
        error("add_pre_emit: expected a function, got a "..type(pre_emit_func));
    end
    get_node(event_name).pre_emits:push_back(pre_emit_func)
end

function remove_pre_emit(event_name, pre_emit_func)
    if unused_event(event_name) then return end
    get_node(event_name).pre_emits:remove(pre_emit_func)    
end

function add_post_emit(event_name, post_emit_func)
    if (type(post_emit_func) ~= "function") then
        error("add_pre_emit: expected a function, got a "..type(post_emit_func));
    end 
    get_node(event_name).post_emits:push_front(post_emit_func)
end

function remove_post_emit(event_name, post_emit_func)
    if unused_event(event_name) then return end
    get_node(event_name).post_emits:remove(post_emit_func)
end

function stop()
    stopped = true
end

function clear(event_name)
    events = {} 
end
