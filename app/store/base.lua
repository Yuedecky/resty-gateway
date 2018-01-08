local Object = require("app.lib.classic")
local sformat = string.format

local Store = Object:exetend()

function Store:new(name)
    self._name = name
end

function Store:set(k,v)
    ngx.log(ngx.DEBUG,sformat("store\"".. self._name .. "\",set= {k:%s,v:%s}",k,v))
end

function Store:get(k)
    ngx.log(ngx.DEBUG,sformat("store\"" .. self._name .. "\",get = {k:%s}",k))
end
return Store
