"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[747],{2464:n=>{n.exports=JSON.parse('{"functions":[{"name":"__index","desc":"Return Maid\'s method if exist or object from `Closet` by given index *(could be nil)*","params":[{"name":"index","desc":"","lua_type":"any"}],"returns":[{"desc":"","lua_type":"((...any) -> (...any)) | Garbage?"}],"function_type":"static","source":{"line":62,"path":"src/Maid/init.lua"}},{"name":"__newindex","desc":" \\n\\nYou can add items into Maid by setting value on index\\n \\n:::tip\\n   Use this for frequently used instances, for example: Signal, UI...\\n:::\\n\\n```lua\\nself.myMaid = Maid.new()\\nself.myMaid[\'Frame\'] = Frame -- Attach Frame to Maid\\n\\n-- In other function\\nif self.myMaid[\'Frame\'] then\\n    self.myMaid[\'Frame\'].BackgroundTransparency = 1\\n    ...\\nend\\n ```","params":[{"name":"index","desc":"","lua_type":"any"},{"name":"value","desc":"","lua_type":"Garbage?"}],"returns":[],"function_type":"static","source":{"line":91,"path":"src/Maid/init.lua"}},{"name":"new","desc":"Return new `Maid` object\\n\\n```lua\\nlocal myMaid = Maid.new()\\n```","params":[{"name":"...","desc":"","lua_type":"Garbage?"}],"returns":[{"desc":"","lua_type":"Maid\\r\\n"}],"function_type":"static","source":{"line":106,"path":"src/Maid/init.lua"}},{"name":"Add","desc":"Push Garbage into Maid\\n\\n```lua\\nlocal vfxPart = Instance.new(\'Part\')\\n-- TODO\\n\\nmyMaid:Add(vfxPart)\\n```\\n\\n:::note\\n    Don\'t forget that you can push multiple garbage in one call\\n:::","params":[{"name":"...","desc":"","lua_type":"Garbage"}],"returns":[{"desc":"","lua_type":"...Garbage\\r\\n"}],"function_type":"method","source":{"line":126,"path":"src/Maid/init.lua"}},{"name":"Destroy","desc":"Clean Maid from Garbage\\n\\n ```lua\\n local myMaid = Maid.new()\\n myMaid[\'testInstance\'] = Instance.new(\'Part\')\\n     \\n print(myMaid[\'testInstance\']) -- Part\\n\\n myMaid:Destroy()\\n\\n print(myMaid[\'testInstance\']) -- nil\\n ```","params":[],"returns":[],"function_type":"method","source":{"line":148,"path":"src/Maid/init.lua"}},{"name":"Clean","desc":"*Allias of `Maid:Destroy()`*\\n\\n```lua\\nlocal myMaid = Maid.new()\\nmyMaid[\'testInstance\'] = Instance.new(\'Part\')\\n    \\nprint(myMaid[\'testInstance\']) -- Part\\n\\nmyMaid:Clean()\\n\\nprint(myMaid[\'testInstance\']) -- nil\\n```","params":[],"returns":[],"function_type":"method","source":{"line":170,"path":"src/Maid/init.lua"}}],"properties":[{"name":"Closet","desc":"Store all garbage in `Maid` object","lua_type":"{ [any] : Garbage }","private":true,"source":{"line":31,"path":"src/Maid/init.lua"}}],"types":[{"name":"Garbage","desc":"#### Type of objects that contains in `Closet`\\nTable used as `Garbage` should implement `Destroy` method\\n\\n```lua\\n-- Requires\\nlocal Signal = require(Packages.Signal)\\n\\nlocal myMaid = Maid.new()\\nlocal mySignal = myMaid:Add(Signal.new()) -- Signal implement Destroy method\\n```","lua_type":"Instance | table | RBXScriptConnection","source":{"line":22,"path":"src/Maid/init.lua"}}],"name":"Maid","desc":" \\nComponent for preventing memory leaks","source":{"line":36,"path":"src/Maid/init.lua"}}')}}]);