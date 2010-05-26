package = "LuaNotify"
version = "1.0-1"
source = {
   url = "http://..." -- We don't have one yet
}
description = {
   summary = "Lua package providing tools for implementing observer programming pattern",
   detailed = [[
       LuaNotify is inspired on many libraries that do event dispatching, like py-notify, GSignals, QT event system, wxWidgets event system, etc.
But we tried to do something different that can make use of Lua resources
and to be more Lua-ish as possible.
   ]],
   homepage = "http://github.com/katcipis/luanotify", 
   license = "LGPL" 
}
dependencies = {
   "lua >= 5.1",
   "lunit >= 0.4"
}
build = {
   type = "builtin",
   modules = {
      ["luanotify.event"]  = "luanotify/event.lua",
      ["luanotify.signal"] = "luanotify/signal.lua"
   }
}


