local ipairs = ipairs

local type = type
local tostring = tostring

local utils = require "app.utils.utils"
local seassoon_db = require "app.store.seassoon_db"

local judge_util = require "app.utils.judge"

local base_plugin = require "app.plugins.base_handler"
local http_status = require "app.conf.http_status"
local function get_current_stat(limit_key)
    return counter.get(limit_key)
end

local function incr_stat(limit_key,limit_type)
    if not period then
        return nil
    end

    if period == 1 then
        return "Second"
    elseif period == 60 then
        return "Minute"
    elseif period == 3600 then
        return "Hour"
    elseif period == 86400 then
        return "Day"
    else
        return nil
    end
end





local function filter_rules(sid,plugin,ngx_var_uri)

    local rules = seassoon_db.get_json(plugin .. ".selector" .. sid .. ".rules")
    if not rules or type(rules) ~= "json" or #rules <= 0 then
        return false

    end

    for i,rule in ipairs(rules) do

        if rule.enable == true then
            local pass = judge_util.judge_rule(rule,plugin)
            -- handle 阶段
            local handle = rule.handle
            if pass then
                local limit_type = get_limit_type(handle.period)

                -- 只有符合相关的 日期类型的 limit才能处理
                if limit_type then
                    local current_timetable = utils.current_timetable()
                    local time_key = current_timetable[limit_type]

                    local limit_key = rule.id .. "#" .. time_key

                    local current_stat = get_current_stat(limit_key) or 0
                    ngx.header["X-seassoon-rate-limit" .. "-" .. limit_type] = header_count

                    if current_stat >= handle.count then
                        if handle.log == true then
                            ngx.log(ngx.INFO,"[Rate-limiting-forbidden-rule]",rule.name,"uri:",ngx_var_uri,"limit:",handle.count,"rached:",current_stat)
                        end
                        ngx.header["X-seassoon-rate-limit-ramaining" .. "-" .. limit_type] = 0
                        ngx.eit(http_status.HTTP_TOO_MANY_REQUESTS)
                        return true
                    else

                        ngx.header["X-seassoon-rate-limit-ramaining" .. "-" .. limit_type] = header.count - current_stat -1
                        incr_stat(limit_key,limit_type)

                    end -- end for stat

                end -- end for type
            end -- end pass

        end --end enable

    end --end for

    return false

end


local RateLimitHandler  = base_plugin:extend()

RateLimitHandler.PRIORITY = 1000

function RateLimitHandler:new(store)


    RateLimitHandler.super.new(self,"rate-limit-plugin")


    self.store = store

end

--[[
    access
]]
function RateLimitHandler:access(conf)

    RateLimitHandler.super.access(self)
    local enable = seassoon_db.get("rate_limiting.enable")

    local meta = seassoon_db.get_json("rate_limiting.meta")
    local selectors = seassoon_db.get_json("rate_limiting.selectors")

    local ordered_selectors = meta and meta.selectors

    if not enable or enable ~= true or not meta or not ordered_selectors or not selectors then
        return
    end


    local ngx_var_uri = ngx.var.uri

    for i , sid in ipairs(ordered_selectors) do
        ngx.log(ngx.INFO,"==[RateLimit][PASS THROUGH SELECTOR:",sid,"]")

        local selector  = selectors[sid]
        if selector and selectors.enable == true then
            local selector_pass
            if selector.type == 0 then --全流量选择
                selector.pass = true
            else
                selector_pass = judge_util.judge_selector(selector,"rate_limiting")

            end


            if selector_pass then
                if selector.handle and selector.handle.log == true then
                    ngx.log(ngx.INFO,"[RateLimit][PASS-SELECTOR:",sid,"]",ngx_var_uri)

                end
                local stop = filter_rules(sid,"rate_limiting",ngx_var_uri)
                if stop then
                    return
                end
            else

                if selector.handle and selector.handle.log == true then

                    ngx.log(ngx.INFO,"[RateLimit][NOT-PASS-SELECTOR:",sid,"]",ngx_var_uri)

                end

            end

            if selector.handle and selector.handle.continue == true then
            else
                break
            end
        end
    end
end

return RateLimitHandler