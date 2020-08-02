package = "EasyBlockList"
version = "U.0.0"
source = {
   url = "git://github.com/Famous5000/EasyBlockList",
   tag = "U.0.0"
}
description = {
   summary = "A piece of code that generates blocks for ease of use.",
   detailed = [[
      This script is designed to run on your computer.
      Running it will give you a bunch of prompts;
      once you finish the prompts, the blocks will be auto-generated.
   ]],
   homepage = "http://...", -- We don't have one yet
   license = "MIT/X11" -- or whatever you like
}
dependencies = {
   "lua >= 5.2, <= 5.2.4"
   -- If you depend on other rocks, add them here
}
build = {
   type = "builtin",
   modules = {
      EBL = "src/blockgen.lua"
   }
}
