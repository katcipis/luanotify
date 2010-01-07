--[[
   Copyright (C) 2010 Digitro Corporation <www.digitro.com.br>
 
   @author Paulo Pizarro  <paulo.pizarro@gmail.com>
   @author Tiago Katcipis <tiagokatcipis@gmail.com>
 
   This file is part of LuaNotify.
 
   LuaNotify is free software: you can redistribute it and/or modify
   it under the terms of the GNU Lesser General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
 
   LuaNotify is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU Lesser General Public License for more details.
 
   You should have received a copy of the GNU Lesser General Public License
   along with Luasofia.  If not, see <http://www.gnu.org/licenses/>.
--]]

Signal = {} --Class attributes and methods goes on this table.

-- private functions

local function get_handler_table(handlers, handler_function)
          for pos, handler_table in ipairs(handlers) do
              if(handler_table.handler == handler_function) then
                  return pos, handler_table
              end
          end
      end

local function get_function_position(func_table, target_func)
          for pos, func in ipairs(func_table) do
              if(func == target_func) then
                  return pos
              end
          end
      end


-- Class definition and methods

function Signal:new (object)
    object = object or {}      --create table if user does no provide one.
    setmetatable(object, self) -- self is the Signal table. Set the metatable of the new object as the Signal table (inherits Signal).
    self.__index = self

    -- create all the instance state data.
    object._handlers = {}
    object._set_up_funcs  = {}
    object._tear_down_funcs = {}
    return object
end


function Signal:disconnect(handler_function)
    local pos, handler_table = get_handler_table(self._handlers, handler_function)
    if(pos) then table.remove(self._handlers, pos) end
end


function Signal:connect(handler_function)
    if(not get_handler_table(self._handlers, handler_function)) then
        table.insert(self._handlers, { handler = handler_function,
                                       block   = 0 })
    end
end


function Signal:block(handler_function)
    local _, handler_table = get_handler_table(self._handlers, handler_function)
    if(handler_table) then
        handler_table.block = handler_table.block + 1
    end
end


function Signal:unblock(handler_function)
    local _, handler_table = get_handler_table(self._handlers, handler_function)
    if(handler_table) then
        if(handler_table.block > 0) then
            handler_table.block = handler_table.block - 1
        end
    end
end


function Signal:emit(...)
    for _,set_up in ipairs(self._set_up_funcs) do set_up() end

    for _,handler_table in ipairs(self._handlers) do 
        if(handler_table.block == 0) then
            handler_table.handler(...)
        end
    end

    for _,tear_down in ipairs(self._tear_down_funcs) do tear_down() end
end


function Signal:emit_with_accumulator(accumulator, ...)

end


function Signal:add_set_up(set_up_func)
    if(not get_function_position(self._set_up_funcs, set_up_func)) then
        table.insert(self._set_up_funcs, set_up_func)
    end
end


function Signal:remove_set_up(set_up_func)
    local pos = get_function_position(self._set_up_funcs, set_up_func)
    if(pos) then table.remove(self._set_up_funcs, pos) end
end


function Signal:add_tear_down(tear_down_func)
    if(not get_function_position(self._tear_down_funcs, tear_down_func)) then
        table.insert(self._tear_down_funcs, tear_down_func)
    end
end


function Signal:remove_tear_down(tear_down_func)
    local pos = get_function_position(self._tear_down_funcs, tear_down_func)
    if(pos) then table.remove(self._tear_down_funcs, pos) end
end


function Signal:stop()

end
