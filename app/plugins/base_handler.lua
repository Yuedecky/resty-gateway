local Object = require("seassoon.app.lib.classic")
local BasePlugin = Object:extend()

function BasePlugin:new(name)
    self._name = name
end

function BasePlugin.get_name()
    return self._name
end

function BasePlugin.init_worker()
    ngx.log(ngx.DEBUG,"executing plugin:",self._name,":init_worker")
end

function BasePlugin.redirect()
    ngx.log(ngx.DEBUG,"executing plugin:",self._name,":redirect")
end

function BasePlugin.rewrite()
    ngx.log(ngx.DEBUG,"executing plugin:",self._name,":rewrite")
end

