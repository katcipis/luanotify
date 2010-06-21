---------------------------------------------------------------------------------
-- Copyright (C) 2010 Tiago Katcipis <tiagokatcipis@gmail.com>
-- Copyright (C) 2010 Paulo Pizarro  <paulo.pizarro@gmail.com>
-- 
-- Paulo Pizarro  <paulo.pizarro@gmail.com>
-- Tiago Katcipis <tiagokatcipis@gmail.com>

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

---
-- @class module
-- @name event
-- @description Event Class.
-- @author <a href="mailto:tiagokatcipis@gmail.com">Tiago Katcipis</a>
-- @author <a href="mailto:paulo.pizarro@gmail.com">Paulo Pizarro</a>
-- @copyright 2010 Tiago Katcipis, Paulo Pizarro.

module(..., package.seeall)

local queue = require "notify.double_queue" 
local separator = ":"


-----------------------------------------------------
-- Class attributes and methods goes on this table --
-----------------------------------------------------
local Event = {}


------------------------------------
-- Metamethods goes on this table --
------------------------------------
local Event_mt = { __index = Event }


---------------------------------
-- Private methods definition --
---------------------------------
local function new_node()
    return { handlers   = queue.new(),
             pre_emits  = queue.new(),
             post_emits = queue.new(),
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


local function get_node(self, event_name)
    local events_names = get_nodes_names(event_name)
    local current_node = self.events[events_names[1]] or new_node()

    self.events[events_names[1]] = current_node
    for i=2, #events_names do
        sub_node = current_node.subevents[events_names[i]] or new_node()
        current_node.subevents[events_names[i]] = sub_node
        current_node = sub_node
    end
    return current_node
end


local function unused_event(self, event_name)
    local events_names = get_nodes_names(event_name)
    local current_node = self.events[events_names[1]] 

    if not current_node then return true end

    for i=2, #events_names do
        sub_node = current_node.subevents[events_names[i]] 
        if not sub_node then return true end
        current_node = sub_node
    end

    return false
end

local function event_iterator(self, event_name)
    local events_names = get_nodes_names(event_name)
    local i = 2
    local current_node = self.events[events_names[1]]

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


local function call_pre_emits(self, event_name)
    local nodes = queue.new()
    local reversed_nodes = queue.new()

    for node in event_iterator(self, event_name) do
        for pre_emit in node.pre_emits:get_iterator() do pre_emit(event_name) end
        nodes:push_back(node)
        reversed_nodes:push_front(node)
    end

    return nodes, reversed_nodes
end


local function call_post_emits(event_name, reversed_nodes)
    for node in reversed_nodes:get_iterator() do
        for post_emit in node.post_emits:get_iterator() do post_emit(event_name) end
    end
end


local function call_handlers(self, params)
    for node in params.nodes:get_iterator() do
        for handler in node.handlers:get_iterator() do
            if(self.stopped) then return end
            if(node.blocked_handlers[handler] == 0) then
                if(params.accumulator) then
                    params.accumulator(handler(params.event_name, unpack(params.args)))
                else
                    handler(params.event_name, unpack(params.args))
                end
            end
        end
    end
end

--------------------------
-- Constructor function --
--------------------------

---
-- Creates a new Event object.
-- @return The new Event object.
function new()
    local object = {}
    -- set the metatable of the new object as the Signal_mt table (inherits Signal).
    setmetatable(object, Event_mt)

    -- create all the instance state data.
    object.stopped = false
    object.events  = {}
    return object
end


----------------------------------
-- Class definition and methods --
----------------------------------

---
-- Connects a handler function on this event.
-- @param event_name       - The event name (eg: mouse::click or just mouse). 
-- @param handler_function - The function that will be called when the event_name is emitted.
function Event:connect(event_name, handler_function)
    if (type(handler_function) ~= "function") then
        error("connect: expected a function, got a "..type(handler_function));
    end

    local node = get_node(self, event_name)
    node.handlers:push_back(handler_function)

    if not node.blocked_handlers[handler_function] then
        node.blocked_handlers[handler_function] = 0
    end
end

---
-- Disconnects a handler function on this event.
-- @param event_name       - The event name (eg: mouse::click or just mouse). 
-- @param handler_function - The function that will be disconnected.
function Event:disconnect(event_name, handler_function)
    if unused_event(self, event_name) then return end

    local node = get_node(self, event_name)
    node.handlers:remove(handler_function)
    node.blocked_handlers[handler_function] = nil
end

---
-- Does not execute the given handler function when the give event is emitted until it is unblocked. 
-- It can be called several times for the same handler function.
-- @param event_name - The event name (eg: mouse::click or just mouse).
-- @param handler_function - The handler function that will be blocked.
function Event:block(event_name, handler_function)
    if unused_event(self, event_name) then return end

    local node = get_node(self, event_name)
    local block = node.blocked_handlers[handler_function]
    if block then
        node.blocked_handlers[handler_function] = block + 1
    end
end

---
-- Unblocks the handler function from the given event. The calls to unblock must match the calls to block.
-- @param event_name - The event name (eg: mouse::click or just mouse).
-- @param handler_function - The handler function that will be unblocked.
function Event:unblock(event_name, handler_function)
    if unused_event(self, event_name) then return end

    local node = get_node(self, event_name)
    if node.blocked_handlers[handler_function] and 
       node.blocked_handlers[handler_function] > 0 then

        node.blocked_handlers[handler_function] = node.blocked_handlers[handler_function] - 1
    end
end

---
-- Emits an event and all handler functions connected to it will be called.
-- Example: Emiting an event: "event1::event2::event3" will call all handlers connected to "event1". 
-- Then handlers connected to "event1::event2" and at last handlers connected to "event1::event2::event3". 
-- Emiting "event1::event2" will call handlers connected to "event1" and "event1::event2" only. 
-- Emiting "event1" will call handlers connected only to "event1". 
-- @param event_name - The event name (eg: mouse::click or just mouse).
-- @param ...        - A optional list of parameters, they will be repassed to the handler functions connected to this event.
function Event:emit(event_name, ...)
    self.stopped = false
    local nodes, reversed_nodes = call_pre_emits(self, event_name)
    call_handlers(self, {event_name=event_name, nodes=nodes, args={...}})
    call_post_emits(event_name, reversed_nodes)
end


---
-- Typical emission discards handlers return values completely. 
-- This is most often what you need: just inform the world about something. 
-- However, sometimes you need a way to get feedback. 
-- For instance, you may want to ask: “is this value acceptable, eh?”
-- This is what accumulators are for. Accumulators are specified to events at emission time. 
-- They can combine, alter or discard handlers return values, post-process them or even stop emission. 
-- Since a handler can return multiple values, accumulators can receive multiple args too. 
-- Following Lua flexible style we give the user the freedom to do whatever he wants with accumulators. 
-- If you are using the hierarchic event system the behaviour of handlers calling is similar to the emit function.
-- @param event_name  - The event name (eg: mouse::click or just mouse). 
-- @param accumulator - Function that will receive handlers results or a table to accumulate 
--                      all the handlers returned values.
-- @param ...         - A optional list of parameters, they will be repassed to the handler 
--                      functions connected to this signal.
function Event:emit_with_accumulator(event_name, accumulator, ...)
    if (not (type(accumulator) == "function" or type(accumulator) == "table")) then
        error("emit_with_accumulator: expected a function or a table, got a "..type(accumulator));
    end
    self.stopped = false
    local nodes, reversed_nodes = call_pre_emits(self, event_name)
    call_handlers(self, {event_name=event_name, nodes=nodes, accumulator=accumulator, args={...}})
    call_post_emits(event_name, reversed_nodes)
end


---
-- Adds a pre_emit func, pre_emit functions can't be blocked, only added or removed. 
-- They can't have their return collected by accumulators, they will not receive any data 
-- passed on the emission and they are always called before ANY handler is called. 
-- This is useful when you want to perform some global task before handling an event, 
-- like opening a socket that the handlers might need to use or a opening a database. 
-- pre_emit functions can make sure everything is ok before handling an event, reducing 
-- the need to do this check_ups inside the handler functions itself (sometimes multiple times). 
-- They are called on a queue (FIFO) policy based on the order they added. 
-- When using hierarchy, pre_emission happen top-bottom. For example, with a mouse::button1 event, 
-- first the pre_emit functions on mouse will be called, then mouse::button1 post_emit functions will be called.
-- @param event_name    - The event name (eg: mouse::click or just mouse).
-- @param pre_emit_func - The pre_emit function.
function Event:add_pre_emit(event_name, pre_emit_func)
    if (type(pre_emit_func) ~= "function") then
        error("add_pre_emit: expected a function, got a "..type(pre_emit_func));
    end
    get_node(self, event_name).pre_emits:push_back(pre_emit_func)
end


---
-- Removes a pre-emit func from the given event.
-- @param event_name - The event name (eg: mouse::click or just mouse). 
-- @param pre_emit_func - The pre_emit function.
function Event:remove_pre_emit(event_name, pre_emit_func)
    if unused_event(self, event_name) then return end
    get_node(self, event_name).pre_emits:remove(pre_emit_func)    
end


---
-- Adds a post_emit function, post_emit functions can't be blocked, only added or removed, 
-- they can't have their return collected by accumulators, they will not receive any data passed 
-- on the emission and they are always called after ALL handlers where called. 
-- This is useful when you want to perform some global task after handling an event, 
-- like closing a socket or a database that the handlers might need to use or do some cleanup. 
-- post_emit functions can make sure everything is released after handling an event, reducing the need 
-- to do this check_ups inside some handler function, since some resources can be shared by multiple handlers. 
-- They are called on a stack (LIFO) policy  based on the order they added. When using hierarchy, 
-- post_emission happen bottom-top. For example, with a mouse::button1 event, first the post_emit 
-- functions on mouse::button1 will be called, then mouse post_emit functions will be called.
-- @param event_name - The event name (eg: mouse::click or just mouse). 
-- @param post_emit_func - The post_emit function.
function Event:add_post_emit(event_name, post_emit_func)
    if (type(post_emit_func) ~= "function") then
        error("add_pre_emit: expected a function, got a "..type(post_emit_func));
    end 
    get_node(self, event_name).post_emits:push_front(post_emit_func)
end


---
-- Removes a post-emit func from the given event. 
-- @param event_name - The event name (eg: mouse::click or just mouse). 
-- @param post_emit_func - The post_emit function.
function Event:remove_post_emit(event_name, post_emit_func)
    if unused_event(self, event_name) then return end
    get_node(self, event_name).post_emits:remove(post_emit_func)
end

---
-- Has effect only during a emission and will stop only this particular emission of the event.
-- Usually called inside a pre-emit (when a condition fail) or on any handler.
function Event:stop()
    self.stopped = true
end

---
-- Removes all pre/post-emits and handlers from the given event_name.
-- If no name is given all pre/post-emits and handlers will be removed.
-- @param event_name - The name of the event that will be cleared, or nil to clear all events.
function Event:clear(event_name)
    if (not event_name) then
        self.events = {} 
        return
    end
end

----------------------
-- Public functions --
----------------------
local global_event = new()

--- 
-- Usefull when someone wants to use events that will propagate trough the entire system. 
-- Always returns the same event object, in this way is easy to the entire system to share the same event instance.
-- @return An event to use on global events.
function get_global_event()
   return global_event 
end
