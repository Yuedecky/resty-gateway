local server = require "api.server"

-- 
local srv = server:new(context.config,context.store)

return srv:get_app()