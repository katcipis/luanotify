---
-- Signal object implementation.
-- @class module
-- @name notify.signal


-- Copyright (C) 2010 Tiago Katcipis <tiagokatcipis@gmail.com>
-- Copyright (C) 2010 Paulo Pizarro  <paulo.pizarro@gmail.com>
-- 
-- author Paulo Pizarro  <paulo.pizarro@gmail.com>
-- author Tiago Katcipis <tiagokatcipis@gmail.com>

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


local require = require
local setmetatable = setmetatable
local Queue = require "notify.double-queue"

local Signal = {}

-- Class attributes and methods goes on this table --
local SignalObject = {} 


-- Metamethods goes on this table --
local SignalObject_mt = { __index = SignalObject }


-- Class definition and methods --

---
-- Disconnects a handler function from this signal, the function will no longer be called.
-- Example:
--
--    local signal = require "notify.signal"
--    local s = signal.new()
--
--    function handler(arg)
--        print(arg)
--    end
--
--    s:connect(handler)
--    s:emit("example") -- example gets printed
--    s:disconnect(handler)
--    s:emit("example") -- nothing gets printed
--
-- @param handler_function – The function that will be disconnected.
function SignalObject:disconnect(handler_function)
    self.handlers:remove(handler_function)
    self.handlers_block[handler_function] = nil
end


---
-- Connects a handler function on this signal, all handlers connected will be called 
-- when the signal is emitted with a FIFO  behaviour (The first connected will be the first called).
-- Example:
--    local signal = require "notify.signal"
--
--    function handler1(arg)
--        print(arg.."1")
--    end
--    function handler2(arg)
--        print(arg.."2")
--    end
--
--    local s = signal.new()
--    s:connect(handler1)
--    s:connect(handler2)
--    s:emit("example") -- example1 gets printed before example2.
--
-- @param handler_function – The function that will be called when this signal is emitted.
function SignalObject:connect(handler_function)
    if(not self.handlers_block[handler_function]) then
        self.handlers_block[handler_function] = 0
        self.handlers:push_back(handler_function)
    end
end


---
-- Does not execute the given handler function when the signal is emitted until it is unblocked. 
-- It can be called several times for the same handler function.
-- Example:
--
--    local signal = require "notify.signal"
--    local s = signal.new()
--    
--    function handler(arg)
--        print(arg)
--    end
--    
--    s:connect(handler)
--    s:emit("example") -- example gets printed
--    
--    s:block(handler)
--    s:emit("example") -- nothing gets printed
--
-- @param handler_function – The handler function that will be blocked.
function SignalObject:block(handler_function)
    if(self.handlers_block[handler_function]) then
        self.handlers_block[handler_function] = self.handlers_block[handler_function] + 1
    end
end


---
-- Unblocks the given handler function, this handler function will be executed on 
-- the order it was previously connected, and it will only be unblocked when 
-- the calls to unblock are equal to the calls to block.
-- Example:
--
--    local signal = require "notify.signal"
--    local s = signal.new()
--    
--    function handler(arg)
--        print(arg)
--    end
--    
--    s:connect(handler)
--    s:emit("example")  -- example gets printed
--    
--    s:block(handler)
--    s:emit("example") -- nothing gets printed
--    s:block(handler)
--    s:emit("example") -- nothing gets printed
--    
--    s:unblock(handler)
--    s:emit("example") -- nothing gets printed
--    s:unblock(handler)
--    s:emit("example") -- example gets printed
--
-- @param handler_function – The handler function that will be unblocked.
function SignalObject:unblock(handler_function)
    if(self.handlers_block[handler_function]) then
        if(self.handlers_block[handler_function] > 0) then
            self.handlers_block[handler_function] = self.handlers_block[handler_function] - 1
        end
    end
end


---
-- Emits a signal calling the handler functions connected to this signal passing the given args.
--
--    local signal = require "notify.signal"
--    local s = signal.new()
--    
--    function handler1(arg1, arg2)
--        print(arg1)
--        print(arg2)
--    end
--    
--    function handler2(arg)
--        print(arg)
--    end
--    
--    s:connect(handler1)
--    s:connect(handler2)
--    s:emit("example") -- a nil will get printed because only one argument was passed
--    s:emit("example1", "example2") -- No nil will get printed.
--    s:emit() -- Only nils will get printed because no argument was passed.
--
-- @param … – A optional list of parameters, they will be repassed to the handler functions connected to this signal.
function SignalObject:emit(...)
    self.signal_stopped = false

    for set_up in self.pre_emit_funcs:get_iterator() do set_up() end

    for handler in self.handlers:get_iterator() do 
        if(self.signal_stopped) then break end
        if(self.handlers_block[handler] == 0) then
            handler(...)
        end
    end

    for tear_down in self.post_emit_funcs:get_iterator() do tear_down() end
end


---
-- Typical signal emission discards handler return values completely. 
-- This is most often what you need: just inform the world about something. 
-- However, sometimes you need a way to get feedback. For instance, 
-- you may want to ask: “is this value acceptable ?”
-- This is what accumulators are for. Accumulators are specified to signals at emission time. 
-- They can combine, alter or discard handler return values, post-process them or even stop emission. 
-- Since a handler can return multiple values, accumulators can receive multiple args too, following 
-- Lua flexible style user has the freedom to do whatever he wants with accumulators.
--
--    local signal = require "notify.signal"
--    local s = signal.new()
--
--    function handler1(arg)
--        return arg * 2
--    end
--
--    function handler2(arg)
--        return arg * 3
--    end
--    
--    local result = {}
--    function accum(arg)
--        result[#result+1] = arg
--    end
--    
--    s:connect(handler1)
--    s:connect(handler2)
--    
--    s:emit_with_accumulator(accum, 2)
--    
--    for k,v in ipairs(result) do  -- print 4, 6
--        print(v)
--    end
--
-- @param accumulator – Function that will accumulate handlers results.
-- @param … – A optional list of parameters, they will be repassed to the handler functions connected to this signal.
function SignalObject:emit_with_accumulator(accumulator, ...)
    self.signal_stopped = false;

    for set_up in self.pre_emit_funcs:get_iterator() do set_up() end

    for handler in self.handlers:get_iterator() do 
        if(self.signal_stopped) then break end
        if(self.handlers_block[handler] == 0) then
            accumulator(handler(...))
        end
    end

    for tear_down in self.post_emit_funcs:get_iterator() do tear_down() end
end


---
-- Adds a pre_emit func, pre_emit functions cant be blocked, only added or removed, 
-- they cannot have their return collected by accumulators, will not receive any data passed 
-- on the emission and they are always called before ANY handler is called. 
-- This is useful when you want to perform some global task before handling an event, 
-- like opening a socket that the handlers might need to use or a database, pre_emit functions 
-- can make sure everything is ok before handling an event, reducing the need to do this check_ups 
-- inside the handler function. They are called on a queue (FIFO) policy based on the order they added.
--
--    local signal = require "notify.signal"
--    local s = signal.new()
--    
--    function handler1()
--        print(1)
--    end
--    
--    function handler2()
--        print(2)
--    end
--    
--    function pre_emit()
--        print("0")
--    end
--    
--    s:connect(handler1)
--    s:connect(handler2)
--    s:emit() -- 1 and 2 printed.
--    s:add_pre_emit(pre_emit)
--    s:emit() -- 0,1 and 2 are printed.
--
-- @param pre_emit_func – The pre_emit function.
function SignalObject:add_pre_emit(pre_emit_func)
    self.pre_emit_funcs:push_back(pre_emit_func)
end


---
-- Removes the pre_emit function
-- @param pre_emit_func – The pre_emit function.
function SignalObject:remove_pre_emit(pre_emit_func)
    self.pre_emit_funcs:remove(pre_emit_func)
end


---
-- Adds a post_emit function, post_emit functions cant be blocked, only added or removed, 
-- they cannot have their return collected by accumulators, they will not receive any data 
-- passed on the emission and they are always called after ALL handlers where called. 
-- This is useful when you want to perform some global task after handling an event, 
-- like closing a socket that the handlers might need to use or a database or do some cleanup. 
-- post_emit functions can make sure everything is released after handling an event, 
-- reducing the need to do this check_ups inside some handler function, since some resources 
-- can be shared by multiple handlers. They are called on a stack (LIFO) policy based on the order they added.
-- Example:
--
--    local signal = require "notify.signal"
--    local s = signal.new()
--    
--    function handler1()
--        print(1)
--    end
--    
--    function handler2()
--        print(2)
--    end
--    
--    function post_emit()
--        print("3")
--    end
--    
--    s:connect(handler1)
--    s:connect(handler2)
--    s:emit() -- 1 and 2 printed.
--    s:add_post_emit(post_emit)
--    s:emit() -- 1, 2 and 3 are printed.
--
-- @param post_emit_func – The post_emit function.
function SignalObject:add_post_emit(post_emit_func)
    self.post_emit_funcs:push_front(post_emit_func)
end

---
-- Removes the post_emit function
-- @param post_emit_func – The post_emit function.
function SignalObject:remove_post_emit(post_emit_func)
    self.post_emit_funcs:remove(post_emit_func)
end


---
-- Stops the current emission, if there is any handler left to be called by the signal it wont be called.
-- Example:
--
--    local signal = require "notify.signal"
--    local s = signal.new()
--    
--    local function handler1()
--        print("hanlder1")
--        signal:stop()
--    end
--    
--    local function handler2()
--        print("hanlder2")
--    end
--    
--    s:connect(handler1)
--    s:connect(handler2)
--    s:emit() -- handler2 never gets printed because handler1 always stops the emission
--
function SignalObject:stop()
    self.signal_stopped = true
end


-- Signal module exported functions --

---
-- Creates a new SignalObject.
function Signal.new ()
    local object = {}
    -- set the metatable of the new object as the SignalObject_mt table (inherits SignalObject).
    setmetatable(object, SignalObject_mt)

    -- create all the instance state data.
    object.handlers_block  = {}
    object.handlers        = Queue.new()
    object.pre_emit_funcs  = Queue.new()
    object.post_emit_funcs = Queue.new()
    object.signal_stopped = false
    return object
end

return Signal

