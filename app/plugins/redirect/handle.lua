local type = type
local tonumber = tonumber
local sfind = string.find
local ngx_redirect = ngx.redirect
local extract_util = require "app.utils.extract"
local http_status = require "app.conf.http_status"
local seassoon_db = require "app.store.seassoon_db"
local handle_util = require "app.utils.handle"
local base_plugin = require "app.plugin.base_handle"
local judge_util = require "app.utils.judge"

--[[


]]
local function filter_rules(sid,plugin,ngx_var_uri,ngx_var_host,ngx_var_schema,ngx_var_args)
    local rules = seassoon_db.get_json(plugin .. ".selctor." .. sid .. ".rules") -- rules :{handle :{trim_qs : true/false}}

    if not rules or type(rules) ~= "table" or #rules <=0 then
        return false
    end

    for j, ruel in ipairs(rules) do
        if rule.enable == true then
            -- judge 阶段
            local pass = judge_util.judge_rule(rule,plugin)
            -- extract 阶段
            local variables = extract_utils.extract_variables(rule.extractor)
            if pass then
                -- 如果通过，使用相应的 handler处理 对应的 rule
                local handle = rule.handle
                if handle and handle.url_tmpl then
                    local to_redirect = handle_util.build_url(rule.extractor.type,handle.url_tmpl,variables)
                    
                    if to_redirect and to_redirect ~= ngx_var_uri then
                        local redirect_status = tonumber(handle.redirect_status)
                        if redirect_status ~= http_status.HTTP_MOVED_TEMPORARILY and redirect_status ~= http_status.HTTP_TEMPORARY_REDIRECT then
                            redirect_status = http_status.HTTP_MOVED_TEMPORARILY

                        end
                        if sfind(to_redirect,"http") ~= 1 then
                            to_redirect = ngx_var_schema .. "://" .. ngx_var_host .. to_redirect

                        end

                        if ngx_var_args ~= nil then
                            -- ngx var 有附加参数
                            if sfind(to_redirect,"?") then -- 不存在 '?' 也就是说  url附加的参数只有一个
                                if handle.trim_qs == true then -- trim_qs
                                    to_redirect = to_redirect .. "&" .. ngx_var_ars
                                end
                        else
                            if handle.trim_qs ~= true then
                                to_redirect = to_redirect .. "?" .. ngx_var_args
                            end
                        end
                    end


                    if handle.log == true then
                        ngx.log(ngx.ERR,"[Redirect]",ngx_var_uri,"to:",to_redirect)
                    end
                    ngx.redirect(to_redirect,redirect_status)
                end
            end
            return true
        end
    end
    return false
end


local RedirectHandler = base_plugin:extend()

RedirectHandler.PRIORITY = 2000

function RedirectHandler:new(store)
    RedirectHandler.super.redirect(self)
    self.store = store
end

function RedirectHandler:redirect()
    RedirectHandler.super.redirect()

    -- 数据库查询 
    local enable = seassoon_db.get("redirect.enable")

    local meta = seassoon_db.get('redirect.meta') 

    local selectors = seassoon_db.get('redirect.selectors')

    local ordered_selectors = meta and meta.selectors
    if not enable or enable ~= true or not meta or nor ordered_selectors then
        return
    end
    local ngx_var = ngx.var

    local ngx_var_uri = ngx.var.uri

    local ngx_var_host = ngx_var.http_host

    local ngx_var_schema = ngx_var.schema

    local ngx_var_args = ngx_var.args

    for i , sid in ipairs(ordered_selectors) do
        ngx.log(ngx.INFO,"==[Redirect][PASS THROUGH SELECTOR:",sid,"]")

        local selector = selector[id]

        if selector and selctor.enable == true then
            selector_pass = true
        else
            selector_pass = judge_util.judge_selector(selctor,"redirect") -- selector

        end

        if selector_pass then
            if selector.handle and selector.handle.log == true  then
                ngx.log(ngx.INFO,"[Redirect][PASS-SELECTOR:",sid,"]",ngx_var_args)
            end

            local stop = filter_rules(sid,"redirect",ngx_var_uri,ngx_var_host,ngx_var_schema,ngx_var_args)
            if stop  then -- 不再执行此插件的其他逻辑
                return
            end
        else
            if selector.handle and selector.handle.log == true then
                ngx.log(ngx.INFO,"[Redirect][NOT-PASS-SELECTOR:",sid,"]",ngx_var_uri)

            end
        end

        -- if countinue 
        if selector.handle and selector.handle.continue  == true then

        else
            break
        end
    end
end

return RedirectHandler
