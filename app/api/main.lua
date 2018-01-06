local server = require "api.server"
-- 创建
local srv = server:new(context.config,context.store)

return srv:get_app()