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
-- along with Luasofia.  If not, see <http://www.gnu.org/licenses/>.
---------------------------------------------------------------------------------
module(..., package.seeall)

require "luanotify.ordered_set"

-----------------------------------------------------
-- Class attributes and methods goes on this table --
-----------------------------------------------------
local Signal = {} 


------------------------------------
-- Metamethods goes on this table --
------------------------------------
local Signal_mt = { __index = Signal, __metatable = "protected" }


--------------------------
-- Constructor function --
--------------------------
function new ()
    local object = {}      
    -- set the metatable of the new object as the Signal_mt table (inherits Signal).
    setmetatable(object, Signal_mt)

    -- create all the instance state data.
    object.handlers_block  = {}
    object.handlers        = luanotify.ordered_set.new()
    object.pre_emit_funcs  = luanotify.ordered_set.new()
    object.post_emit_funcs = luanotify.ordered_set.new()
    object.signal_stopped = false
    return object
end


----------------------------------
-- Class definition and methods --
----------------------------------
function Signal:disconnect(handler_function)
    self.handlers:remove(handler_function)
    self.handlers_block[handler_function] = nil
end


function Signal:connect(handler_function)
    if (type(handler_function) ~= "function") then
        error("connect: expected a function, got a "..type(handler_function));
    end

    if(not self.handlers_block[handler_function]) then
        self.handlers_block[handler_function] = 0
        self.handlers:push_back(handler_function)
    end
end


function Signal:block(handler_function)
    if(self.handlers_block[handler_function]) then
        self.handlers_block[handler_function] = self.handlers_block[handler_function] + 1
    end
end


function Signal:unblock(handler_function)
    if(self.handlers_block[handler_function]) then
        if(self.handlers_block[handler_function] > 0) then
            self.handlers_block[handler_function] = self.handlers_block[handler_function] - 1
        end
    end
end


function Signal:emit(...)
    self.signal_stopped = false;

    for set_up in self.pre_emit_funcs:get_iterator() do set_up() end

    for handler in self.handlers:get_iterator() do 
        if(self.signal_stopped) then break end
        if(self.handlers_block[handler] == 0) then
            handler(...)
        end
    end

    for tear_down in self.post_emit_funcs:get_iterator() do tear_down() end
end


function Signal:emit_with_accumulator(accumulator, ...)
    if (type(accumulator) ~= "function") then
        return
    end

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


function Signal:add_pre_emit(pre_emit_func)
    if (type(pre_emit_func) ~= "function") then
        error("add_pre_emit: expected a function, got a "..type(pre_emit_func));
    end

    self.pre_emit_funcs:push_back(pre_emit_func)
end


function Signal:remove_pre_emit(pre_emit_func)
    self.pre_emit_funcs:remove(pre_emit_func)
end


function Signal:add_post_emit(post_emit_func)
    if (type(post_emit_func) ~= "function") then
        error("add_post_emit: expected a function, got a "..type(post_emit_func));
    end
    self.post_emit_funcs:push_back(post_emit_func)
end


function Signal:remove_post_emit(post_emit_func)
    self.post_emit_funcs:remove(post_emit_func)
end


function Signal:stop()
    self.signal_stopped = true
end

