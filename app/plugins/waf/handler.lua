local ipairs = ipairs
local pairs = pairs
local seassoon_db = require "app.store.seassoon_db"

local judge_util = require "app.utils.judge"
local handle_util = require "app.utils.handle"
local base_handler = require "app.plugin.base_handler"
local stat = require "app.plugins.waf.stat"

local function filter_rules(sid,plugin,ngx_var_uri)
    local rules = seassoon_db.get_json(plugin .. ".selector." .. sid .. ".rules")
    if not rules or type(rules) then
        return false
    end

    for i, rule in ipairs(rules) do
        if rule.enable == true then
            local pass = judge_util.judge_rule(rule,plugin)

            local variables = judge_util.extract_variables(rule.extractor)

            if pass then
                -- 处理 rule
                local handle = rule.handle
                if handle.stat == true then
                    local key = rule.id
                    stat.count(key,1)
                end

                if handle.platform == "allow" then

                    if handle.log == true then
                        ngx.log(ngx.INFO,"[WAF-PASS-RULE]",rule.name,"uri:",ngx_var_uri)
                        --
                    end
                else
                    if handle.log == true then
                        ngx.log(ngx.INFO,"[WAF-FORBIDDEN-RULE],",rule.name,"uri:",ngx_var_uri)
                    end
                    ngx.exit(tonumber(handle.code or 403))
                end

            end

        end

    end
    return false
end

local WAFHandler = base_handler:extend()

WAFHandler.PRIORITY = 2000
function WAFHandler:new(store)
    WAFHandler.super.new(self,"waf-plugin")
    self.store = store
end
function WAFHandler:access(conf)
    WAFHandler.super.access(self)
    local enable = seassoon_db.get("waf.enable")
    local meta = seassoon_db.get_json('waf.meta')
    local selectors = seassoon_db.get_json("waf.seletors")

    local ordered_selectors = meta or meta.selectors

    if not enable or enable ~= true or not meta or not ordered_selectors or not selectors then
        return
    end

    local ngx_var_uri = ngx.var.uri
    for i,sid in ipairs(ordered_selectors) do
        ngx.log(ngx.INFO,"==[WAF][PASS_THROUGH_SELECTOR:",sid,"]")
        local selector = selector[sid]
        if selector and selector.enable == true then
            local selector_pass
            if selector.type == 0 then
                selector_pass = true
            else
                selector_pass = judge_util.judge_selector(selector,"waf") -- selector judge
            end
            if selector_pass then
                if selector.handle and selector.handle.log then
                    ngx.log(ngx.INFO,"[WAF][PASS-SELECTOR:",sid,"]",ngx_var_uri)
                end
                local stop = filter_rules(sid,"waf",ngx_var_uri)

                --
                if stop then
                    return
                end
            else
                if selector.handle and selector.handle.log == true then
                    ngx.log(ngx.INFO,"[WAF][NOT-PASS-SELECTOR:",sid,"]",ngx_var_uri)
                end
            end
            -- if countinue
            if selector.handle and selector.handle.continue == true then

            else
                break
            end
        end



    end
end


return WAFHandler