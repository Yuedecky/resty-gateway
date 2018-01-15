local base_api = require "app.pluigns.base_api"

local common_api = require "app.plugins.common_api"

local package = require "package_info"

local table_insert = table.insert
local api = base_api:new(package.api_name,2)
api:merge_apis(common_api(package.api_name))


api:get("/waf/stat",function(store)
    return function(req,res,next)
        local max_count = req.query.max_count or 500
        local stats = stats:get_all(max_count)
        local statistics = {}
        for i, s in ipairs(stats) do
            local temp  ={
                rule_id = s.rule.id,
                count = s.count
            }
            table_insert(statistics,temp)

        end

        local result = {
            success = true,
            data = {
                statistics = statistics
            }
        }
        res:json(result)
    end
end)
return api