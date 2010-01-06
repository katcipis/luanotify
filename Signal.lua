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

-- Class definition and methods

function Signal:new (object)
    object = object or {}      --create table if user does no provide one.
    setmetatable(object, self) -- self is the Signal table. Set the metatable of the new object as the Signal table (inherits Signal).
    self.__index = self
    object._handlers = {}
    return object
end

function Signal:disconnect(handler_function)
    pos, handler_table = get_handler_table(self._handlers, handler_function)
    if(pos) then table.remove(self._handlers, pos) end
end

function Signal:connect(handler_function)
    table.insert(self._handlers, { handler = handler_function,
                                   block   = 0 })
end

function Signal:block(handler_function)
    pos, handler_table = get_handler_table(self._handlers, handler_function)
    handler_table.block = handler_table.block + 1
end

function Signal:unblock(handler_function)
    pos, handler_table = get_handler_table(self._handlers, handler_function)
    if(handler_table.block > 0) then
        handler_table.block = handler_table.block - 1
    end
end

function Signal:emit(...)
    for _,handler_table in ipairs(self._handlers) do 
        if(handler_table.block == 0) then
            handler_table.handler(...)
        end
    end
end




