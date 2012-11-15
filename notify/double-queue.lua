---
-- A simple double queue implementation.
-- @class module
-- @name notify.double-queue

--
-- Copyright (C) 2010 Tiago Katcipis <tiagokatcipis@gmail.com>
-- Copyright (C) 2010 Paulo Pizarro  <paulo.pizarro@gmail.com>
-- 
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
--

local setmetatable = setmetatable

local DoubleQueue = {}

-- Class attributes and methods goes on this table --
local DoubleQueueObject = {}

-- Metamethods goes on this table --
local DoubleQueueObject_mt = { __index = DoubleQueueObject }


-- Module exported functions --

---
-- Creates a new double queue.
function DoubleQueue.new ()
    local object = setmetatable({}, DoubleQueueObject_mt)

    -- create all the instance state data.
    object.data          = {}
    object.data_position = {}
    object.first         = 1 
    object.last          = 0
    return object
end

-- Private methods --
local function refresh_first(self)
    while(self.first <= self.last) do
        if(self.data[self.first]) then
            return true
        end
        self.first = self.first + 1
    end
end


-- Public methods --

---
-- Check if the queue is empty
-- @return true if it is empty, false otherwise.
function DoubleQueueObject:is_empty()
    return self.first > self.last
end

---
-- Pushes data on the front of the queue.
-- @param data The data thas is being pushed.
function DoubleQueueObject:push_front(data)
    if(self.data_position[data]) then
        return
    end
    self.first = self.first - 1
    self.data[self.first]    = data
    self.data_position[data] = self.first
end

---
-- Pushes data on the back of the queue.
-- @param data The data thas is being pushed.
function DoubleQueueObject:push_back(data)
    if(self.data_position[data]) then
        return
    end
    self.last = self.last + 1
    self.data[self.last]     = data
    self.data_position[data] = self.last
end


---
-- Get the queue iterator.
-- Each call to the iterator function returns the next element.
-- Example:
--
--    for data in queue:get_iterator() do
--        print("mydata: "..tostring(data))
--    end
--
-- @return An iterator function.
function DoubleQueueObject:get_iterator()
    local first = self.first
    local function iterator()
        while(first <= self.last) do
            local data = self.data[first]
            first = first + 1
            if(data) then
                return data
            end
        end    
    end 
    return iterator
end

---
-- Removes the first ocurrence of data from the queue.
-- If the data cant be found on the queue, nothing happens.
-- @param data The data that is going the be removed.
function DoubleQueueObject:remove(data)
    if(not self.data_position[data]) then
        return 
    end
    self.data[self.data_position[data]] = nil
    self.data_position[data]            = nil
    refresh_first(self)
end

return DoubleQueue

