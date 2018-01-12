local base_handler = require "app.plugins.base_handler"
local stat = require "app.plugins.stat.stat"
local StatHandler = base_handler:extend()

StatHandler.PRIORITY = 2000
function StatHandler:new()
    StatHandler.super.new(self,"stat-handler")
end

function StatHandler:init_worker(conf)
    stat.init()
end


function StatHandler:log(conf)
    stat.log()
end

return StatHandler