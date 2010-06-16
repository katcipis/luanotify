h1. Briefing

This module aims to build a generic hierarchic event system. The hierarchic model uses string event names to define what event are you working with. 

For example:
"event"                                       -> Just a normal event.
"event:subevent"                        -> Using the subevent feature.

The subevent system has no constraints, you can do something like that:
"event:subevent:subsubevent" 

The ":" is what defines that you are using hierarchic events, every ":" you put is a new hierarchic level.

When you use single events the behavior is similar to Signal instances. But when you use hierarchic events the behavior changes, some functions have a different behavior, not propagating or propagating on a different way, read the documentation and the "tests":http://github.com/katcipis/Luanotify/blob/master/tests carefully.

h1. event module functions

*new()*
 * @return a new Event object.

Example:
<pre><code class="lua">
local event = require "notify.event"
local e = event.new()
</code></pre>


*get_global_event()*
 * @return An event to use on global events.
Usefull when someone wants to use events that will propagate trough the entire system. Always returns the same event object, in this way is easy to the entire system to share the same event instance.

Example:
<pre><code class="lua">
local event = require "notify.event"
local e_global = event.get_global_event()
-- or just use
event.get_global_event:method()
</code></pre>


h1. Event Class

*connect(event_name, handler_function)*
* @param event_name        - The event name (eg: mouse::click or just mouse). 
* @param handler_function - The function that will be called when the event_name is emitted.

Connects a handler function on this event.

*disconnect(event_name, handler_function)*
* @param event_name        - The event name (eg: mouse::click or just mouse). 
* @param handler_function - The function that will be disconnected.

Disconnects a handler function from this event.

*emit(event_name, [...])*
* @param event_name - The event name (eg: mouse::click or just mouse). 
* @param ...                  - A optional list of parameters, they will be repassed to the handler functions connected to this event.

This function emits an event and all handler functions connected to it will be called.

Example: 
Emiting an event: "event1::event2::event3" will call all handlers connected to "event1", then handlers connected to "event1::event2" and at last handlers connected to "event1::event2::event3". Emiting "event1::event2" will call handlers connected to "event1" and "event1::event2" only. Emiting "event1" will call handlers connected only to "event1". 

Example Code:
<pre><code class="lua">
require "notify.event"
local event = notify.event.new()

function handler1(arg)
    print(arg.."1")
end
function handler2(arg)
    print(arg.."2")
end

event:connect("mouse", handler1)
event:connect("mouse::click". handler2)
event:emit("mouse", "example") -- it gets printed just example1.
event:emit("mouse::click", "example") -- it gets printed example1 then example2.
</code></pre>

*emit_with_accumulator(event_name, accumulator, [...])*
* @param event_name - The event name (eg: mouse::click or just mouse). 
* @param accumulator - Function that will accumulate handlers results.
* @param ...                  - A optional list of parameters, they will be repassed to the handler functions connected to this signal.

Typical emission discards handlers return values completely. This is most often what you need: just inform the world about something. However, sometimes you need a way to get feedback. For instance, you may want to ask: “is this value acceptable, eh?”
This is what accumulators are for. Accumulators are specified to events at emission time. They can combine, alter or discard handlers return values, post-process them or even stop emission. Since a handler can return multiple values, accumulators can receive multiple args too, following Lua flexible style we give the user the freedom to do whatever he wants with accumulators. If you are using the hierarchic event system the behaviour of handlers calling is similar to the emit function.

Example Code:
<pre><code class="lua">
require "notify.event"
local event = notify.event.new()

function handler1(arg)
    return arg * 2
end
function handler2(arg)
    return arg * 3
end
local result = {}
function accum(arg)
    result[#result+1] = arg
end

event:connect("mouse::click", handler1)
event:connect("mouse::click". handler2)
event:emit_with_accumulator("mouse::click", accum, 2)

for k,v in ipairs(result) do  — print 4, 6
    print(v)
end
</code></pre>

*block(event_name, handler_function)*
* @param event_name - The event name (eg: mouse::click or just mouse). 
* @param handler_function - The handler function that will be blocked.

Does not execute the given handler function when the give event is emitted until it is unblocked. It can be called several times for the same handler function.

Example Code:
<pre><code class="lua">
require "notify.event"
local event = notify.event.new()

function handler1(arg)
    print(arg)
end

event:connect("mouse", handler1)
event:emit("mouse", "example") -- example gets printed.

event:block("mouse", handler1);
event:emit("mouse", "example") -- nothing gets printed.
</code></pre>


*unblock(event_name, handler_function)*
* @param event_name - The event name (eg: mouse::click or just mouse). 
* @param handler_function - The handler function that will be unblocked.

Unblocks the handler function from the given event. The calls to unblock must match the calls to block.

Example Code:
<pre><code class="lua">
require "notify.event"
local event = notify.event.new()

function handler1(arg)
    print(arg)
end

event:connect("mouse", handler1)
event:emit("mouse", "example") -- example gets printed.

event:block("mouse", handler1);
event:emit("mouse", "example") -- nothing gets printed.

event:block("mouse", handler1);
event:emit("mouse", "example") -- nothing gets printed.

event:unblock("mouse", handler1);
event:emit("mouse", "example") -- nothing gets printed.
event:unblock("mouse", handler1);
event:emit("mouse", "example") -- example gets printed.
</code></pre>

*add_pre_emit(event_name, pre_emit_func)*
* @param event_name    - The event name (eg: mouse::click or just mouse). 
* @param pre_emit_func - The pre_emit function.

Adds a pre_emit func, pre_emit functions can't be blocked, only added or removed, they can't have their return collected by accumulators, they will not receive any data passed on the emission and they are always called before ANY handler is called. This is useful when you want to perform some global task before handling an event, like opening a socket that the handlers might need to use or a opening a database. pre_emit functions can make sure everything is ok before handling an event, reducing the need to do this check_ups inside the handler functions itself (sometimes multiple times). They are called on a queue (FIFO) policy based on the order they added. When using hierarchy, pre_emission happen top-bottom. For example, with a mouse::button1 event, first the pre_emit functions on mouse will be called, then mouse::button1 post_emit functions will be called.

Example Code:
<pre><code class="lua">
require "notify.event"
local event = notify.event.new()

function handler1()
    print("1")
end
function handler2()
    print("2")
end
function pre_emit()
    print("0")
end

event:connect("mouse::click", handler1)
event:connect("mouse::click", handler2)
event:emit("mouse::click") -- 1 and 2 printed.

event:add_pre_emit("mouse::click", pre_emit)
event:emit("mouse::click") -- 0, 1 and 2 are printed.
</code></pre>

*remove_pre_emit(event_name, pre_emit_func)*
* @param event_name - The event name (eg: mouse::click or just mouse). 
* @param pre_emit_func - The pre_emit function.

Removes a pre-emit func from the given event.

Example Code:
<pre><code class="lua">
require "notify.event"
local event = notify.event.new()

function handler1()
    print("1")
end
function handler2()
    print("2")
end
function pre_emit()
    print("0")
end

event:connect("mouse::click", handler1)
event:connect("mouse::click", handler2)
event:add_pre_emit("mouse::click", pre_emit)

event:emit("mouse::click") -- 0, 1 and 2 are printed.

event:remove_pre_emit("mouse::click", pre_emit);
event:emit("mouse::click") -- 1 and 2 printed.
</code></pre>

*add_post_emit(event_name, post_emit_func)*
* @param event_name - The event name (eg: mouse::click or just mouse). 
* @param post_emit_func - The post_emit function.

Adds a post_emit function, post_emit functions can't be blocked, only added or removed, they can't have their return collected by accumulators, they will not receive any data passed on the emission and they are always called after ALL handlers where called. This is useful when you want to perform some global task after handling an event, like closing a socket or a database that the handlers might need to use or do some cleanup. post_emit functions can make sure everything is released after handling an event, reducing the need to do this check_ups inside some handler function, since some resources can be shared by multiple handlers. They are called on a stack (LIFO) policy  based on the order they added. When using hierarchy, post_emission happen bottom-top. For example, with a mouse::button1 event, first the post_emit functions on mouse::button1 will be called, then mouse post_emit functions will be called.

Example Code:
<pre><code class="lua">
require "notify.event"
local event = notify.event.new()

function handler1()
    print("1")
end
function handler2()
    print("2")
end
function pos_emit()
    print("3")
end

event:connect("mouse::click", handler1)
event:connect("mouse::click", handler2)
event:emit("mouse::click") -- 1 and 2 printed.

event:add_pos_emit("mouse::click", pos_emit)
event:emit("mouse::click") -- 1, 2 and 3 are printed.
</code></pre>

*remove_post_emit(event_name, post_emit_func)*
* @param event_name - The event name (eg: mouse::click or just mouse). 
* @param post_emit_func - The post_emit function.

Removes a post-emit func from the given event. 

Example Code:
<pre><code class="lua">
require "notify.event"
local event = notify.event.new()

function handler1()
    print("1")
end
function handler2()
    print("2")
end
function pos_emit()
    print("3")
end

event:connect("mouse::click", handler1)
event:connect("mouse::click", handler2)
event:add_pos_emit("mouse::click", pos_emit)

event:emit("mouse::click") -- 1, 2 and 3 are printed.

event:remove_pos_emit("mouse::click", pos_emit);
event:emit("mouse::click") -- 1 and 2 printed.
</code></pre>


*stop()*
Use this on a pre_emit function or handler function to stop the current event emission.

Example Code:
<pre><code class="lua">
require "notify.event"
local event = notify.event.new()

function handler1()
    print("handler1")
    event.stop();
end
function handler2()
    print("2")
end

event:connect("mouse", handler1)
event:connect("mouse::click", handler2)

event:emit("mouse::click") -- handler2 never gets printed because handler1 always stops the emission
</code></pre>
