h1. signal module functions

*new()*
 * @return a Signal object.

Example:
<pre><code class="lua">
local signal = require "notify.signal"
local s = signal.new()
</code></pre>


h1. Signal Class

*connect(handler_function)*
* @param handler_function - The function that will be called when this signal is emitted.

Connects a handler function on this signal, all handlers connected will be called when the signal is emitted with a FIFO behaviour (The first connected will be the first called).

Example:
<pre><code class="lua">
local signal = require "notify.signal"

function handler1(arg)
    print(arg.."1")
end
function handler2(arg)
    print(arg.."2")
end

local s = signal.new()
s:connect(handler1)
s:connect(handler2)
s:emit("example") -- example1 gets printed before example2.
</code></pre>


*disconnect(handler_function)*
* @param handler_function - The handler function that will be disconnected.

Disconnects a handler function from this signal, the function will no longer be called.

Example:
<pre><code class="lua">
local signal = require "notify.signal"
local s = signal.new()

function handler(arg)
    print(arg)
end

s:connect(handler)
s:emit("example") -- example gets printed
s:disconnect(handler)
s:emit("example") -- nothing gets printed
</code></pre>

*emit_with_accumulator(accumulator, [...])*
* @param accumulator - Function that will accumulate handlers results.
* @param ...                  - A optional list of parameters, they will be repassed to the handler functions connected to this signal.

Typical signal emission discards handler return values completely. This is most often what you need: just inform the world about something. However, sometimes you need a way to get feedback. For instance, you may want to ask: “is this value acceptable, eh?”
This is what accumulators are for. Accumulators are specified to signals at emission time. They can combine, alter or discard handler return values, post-process them or even stop emission. Since a handler can return multiple values, accumulators can receive multiple args too, following Lua flexible style we give the user the freedom to do whatever he wants with accumulators.

Example:
<pre><code class="lua">
local signal = require "notify.signal"
local s = signal.new()

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

s:connect(handler1)
s:connect(handler2)

s:emit_with_accumulator(accum, 2)

for k,v in ipairs(result) do  -- print 4, 6
    print(v)
end
</code></pre>

*emit([...])*
* @param ... - A optional list of parameters, they will be repassed to the handler functions connected to this signal.

Emits a signal calling the handler functions connected to this signal passing the given args.

Example (This example shows how great can be the flexibility lua gives on function calling with different number os args):
<pre><code class="lua">
local signal = require "notify.signal"
local s = signal.new()

function handler1(arg1, arg2)
    print(arg1)
    print(arg2)
end

function handler2(arg)
    print(arg)
end

s:connect(handler1)
s:connect(handler2)
s:emit("example") -- a nil will get printed because only one argument was passed
s:emit("example1", "example2") -- No nil will get printed.
s:emit() -- Only nils will get printed because no argument was passed.
</code></pre>


*block(handler_function)*
* @param handler_function - The handler function that will be blocked.

Does not execute the given handler function when the signal is emitted until it is unblocked. It can be called several times for the same handler function.

Example:
<pre><code class="lua">
local signal = require "notify.signal"
local s = signal.new()

function handler(arg)
    print(arg)
end

s:connect(handler)
s:emit("example") -- example gets printed

s:block(handler)
s:emit("example") -- nothing gets printed
</code></pre>


*unblock(handler_function)*
* @param handler_function - The handler function that will be unblocked.

Unblocks the given handler function, this handler function will be executed on the order it was previously connected, and it will only be unblocked when the calls to unblock are equal to the calls to block.

Example:
<pre><code class="lua">
local signal = require "notify.signal"
local s = signal.new()

function handler(arg)
    print(arg)
end

s:connect(handler)
s:emit("example")  -- example gets printed

s:block(handler)
s:emit("example") -- nothing gets printed
s:block(handler)
s:emit("example") -- nothing gets printed

s:unblock(handler)
s:emit("example") -- nothing gets printed
s:unblock(handler)
s:emit("example") -- example gets printed
</code></pre>

*add_pre_emit(pre_emit_func)*
* @param pre_emit_func - The pre_emit function.

Adds a pre_emit func, pre_emit functions cant be blocked, only added or removed, they cannot have their return collected by accumulators, will not receive any data passed on the emission and they are always called before ANY handler is called. This is useful when you want to perform some global task before handling an event, like opening a socket that the handlers might need to use or a database, pre_emit functions can make sure everything is ok before handling an event, reducing the need to do this check_ups inside the handler function. They are called on a queue (FIFO) policy based on the order they added. 

Example:
<pre><code class="lua">
local signal = require "notify.signal"
local s = signal.new()

function handler1()
    print(1)
end

function handler2()
    print(2)
end

function pre_emit()
    print("0")
end

s:connect(handler1)
s:connect(handler2)
s:emit() -- 1 and 2 printed.
s:add_pre_emit(pre_emit)
s:emit() -- 0,1 and 2 are printed. 
</code></pre>

*remove_pre_emit(pre_emit_func)*
* @param pre_emit_func - The pre_emit function.

Removes the pre_emit function

Example:
<pre><code class="lua">
local signal = require "notify.signal"
local s = signal.new()

function handler1()
    print(1)
end

function handler2()
    print(2)
end

function pre_emit()
    print("0")
end

s:connect(handler1)
s:connect(handler2)
s:add_pre_emit(pre_emit)
s:emit() -- 0, 1 and 2 are printed.
s:remove_pre_emit(pre_emit)
s:emit() -- 1 and 2 printed. 
</code></pre>


*add_post_emit(post_emit_func)*
* @param post_emit_func - The post_emit function.

Adds a post_emit function, post_emit functions cant be blocked, only added or removed, they cannot have their return collected by accumulators, they will not receive any data passed on the emission and they are always called after ALL handlers where called. This is useful when you want to perform some global task after handling an event, like closing a socket that the handlers might need to use or a database or do some cleanup. post_emit functions can make sure everything is released after handling an event, reducing the need to do this check_ups inside some handler function, since some resources can be shared by multiple handlers. They are called on a stack (LIFO) policy  based on the order they added.

Example:
<pre><code class="lua">
local signal = require "notify.signal"
local s = signal.new()

function handler1()
    print(1)
end

function handler2()
    print(2)
end

function post_emit()
    print("3")
end

s:connect(handler1)
s:connect(handler2)
s:emit() -- 1 and 2 printed.
s:add_post_emit(post_emit)
s:emit() -- 1, 2 and 3 are printed. 
</code></pre>


*remove_post_emit(post_emit_func)*
* @param post_emit_func - The post_emit function.

Removes the post_emit function.

Example:
<pre><code class="lua">
local signal = require "notify.signal"
local s = signal.new()

function handler1()
    print(1)
end

function handler2()
    print(2)
end

function post_emit()
    print("3")
end

s:connect(handler1)
s:connect(handler2)
s:add_post_emit(post_emit)
s:emit() -- 1, 2 and 3 are printed. 
s:remove_post_emit(post_emit)
s:emit() -- 1 and 2 printed.
</code></pre>


*stop()*
Stops signal emission, if there is any handler left to be called by the signal it wont be called.

Example:
<pre><code class="lua">
local signal = require "notify.signal"
local s = signal.new()

local function handler1()
    print("hanlder1")
    signal:stop()
end

local function handler2()
    print("hanlder2")
end

s:connect(handler1)
s:connect(handler2)
s:emit() -- handler2 never gets printed because handler1 always stops the emission
</code></pre>


