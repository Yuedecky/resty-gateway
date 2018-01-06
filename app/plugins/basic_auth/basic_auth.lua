local base_api = require "seassoon.app.plugins.basic_api"
local common_api = require "seassoon.app.common_api"
local api = base_api:new("basic_auth_api",2)

api:merge_apis(common_api("basic_auth"))

return api