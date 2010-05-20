event = require "luanotify.event"

local function handler_function()
end

print("event: mouse::button1::click::pressed")
event.connect("mouse::button1::click::pressed", handler_function)
print("event: ::button1::click::pressed")
event.connect("::button1::click::pressed", handler_function)
print("event: mouse::button1::click::")
event.connect("mouse::button1::click::", handler_function)
print("event: mouse::but:ton1::cli:ck::pressed")
event.connect("mouse::but:ton1::cli:ck::pressed", handler_function)

event.emit("mouse::button")

