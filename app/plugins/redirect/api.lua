local base_api = require "app.plugins.base_api"

local common_api = require "app.plugins.common_api"

local api = base_api:new("redirect-api",2)

api:merge_apis (common_api("redirect"))


return api
