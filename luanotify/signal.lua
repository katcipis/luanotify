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


Signal = {} --Class attributes and methods goes on this table.


-- Class definition and methods

function Signal:new (object)
    -- create table if user does no provide one.
    local object = object or {}      
    -- self is the Signal table. 
    -- set the metatable of the new object as the Signal table (inherits Signal).
    setmetatable(object, self)
    self.__index = self

    -- create all the instance state data.
    object.handlers = {}
    object.pre_emit_funcs  = {}
    object.post_emit_funcs = {}
    object.signal_stopped = false
    return object
end


function Signal:disconnect(handler_function)
    local pos = self.handlers[handler_function]
    if(pos) then 
        table.remove(self.handlers, pos)
        self.handlers[handler_function] = nil
    end
end


function Signal:connect(handler_function)
    if (type(handler_function) ~= "function") then
        error("connect: expected a function, got a "..type(handler_function));
    end

    if(not self.handlers[handler_function]) then
        local pos = #self.handlers + 1
        self.handlers[handler_function] = pos
        self.handlers[pos] = { handler = handler_function, 
                               block = 0 }
    end
end


function Signal:block(handler_function)
    if(self.handlers[handler_function]) then
        local handler_table = self.handlers[self.handlers[handler_function]]
        if(handler_table) then
            handler_table.block = handler_table.block + 1
        end
    end
end


function Signal:unblock(handler_function)
   if(self.handlers[handler_function]) then
       local handler_table = self.handlers[self.handlers[handler_function]]
       if(handler_table) then
           if(handler_table.block > 0) then
               handler_table.block = handler_table.block - 1
           end
       end
    end
end


function Signal:emit(...)
    self.signal_stopped = false;

    for _, set_up in ipairs(self.pre_emit_funcs) do set_up() end

    for _, handler_table in ipairs(self.handlers) do 
        if(self.signal_stopped) then break end
        if(handler_table.block == 0) then
            handler_table.handler(...)
        end
    end

    for _, tear_down in ipairs(self.post_emit_funcs) do tear_down() end
end


function Signal:emit_with_accumulator(accumulator, ...)
    if (type(accumulator) ~= "function") then
        return
    end

    self.signal_stopped = false;

    for _, set_up in ipairs(self.pre_emit_funcs) do set_up() end

    for _, handler_table in ipairs(self.handlers) do 
        if(self.signal_stopped) then break end
        if(handler_table.block == 0) then
            accumulator(handler_table.handler(...))
        end
    end

    for _, tear_down in ipairs(self.post_emit_funcs) do tear_down() end
end


function Signal:add_pre_emit(pre_emit_func)
    if (type(pre_emit_func) ~= "function") then
        error("add_pre_emit: expected a function, got a "..type(pre_emit_func));
    end

    if(not self.pre_emit_funcs[pre_emit_func]) then
        local pos = #self.pre_emit_funcs + 1
        self.pre_emit_funcs[pre_emit_func] = pos
        self.pre_emit_funcs[pos] = pre_emit_func
    end
end


function Signal:remove_pre_emit(pre_emit_func)
    local pos = self.pre_emit_funcs[pre_emit_func]
    if(pos) then
        table.remove(self.pre_emit_funcs, pos)
        self.pre_emit_funcs[pre_emit_func] = nil
    end
end


function Signal:add_post_emit(post_emit_func)
    if (type(post_emit_func) ~= "function") then
        error("add_post_emit: expected a function, got a "..type(pre_emit_func));
    end

    if(not self.post_emit_funcs[post_emit_func]) then
        local pos = #self.post_emit_funcs + 1
        self.post_emit_funcs[post_emit_func] = pos
        self.post_emit_funcs[pos] = post_emit_func
    end
end


function Signal:remove_post_emit(post_emit_func)
    local pos = self.post_emit_funcs[post_emit_func]
    if(pos) then
        table.remove(self.post_emit_funcs, pos)
        self.post_emit_funcs[post_emit_func] = nil
    end
end


function Signal:stop()
    self.signal_stopped = true
end

