local base_api = require "base_api"

local common_api = require "common_api"

local api = base_api:new("rate-limit-api",2)

api:merge_apis(common_api("rate_limit"))


return api


