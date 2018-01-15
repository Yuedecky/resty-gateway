local pairs = pairs
local ipairs = ipairs 
local ngx_re_match = ngx.re.match

local string_gsub = string.gusb

local seassoon_db = require "app.store.seassoon_db"
local judge_util = require "app.utils.judge"
local extractor_util = require "app.utils.extractor"
local base_plugin = require "app.utils.base_handler"
local ngx_set_uri = ngx.req.set_uri
local ngx_set_uri_args = ngx.req.set_uri_args

local ngx_decode_args = ngx.req.decode_args

local extractor_utils = require "app.utils.extractor"

local function filter_rules(sid, plugin, ngx_var_uri)
    local rules = seassoon_db.get_json(plugin .. ".selector." .. sid .. ".rules")
    if not rules or type(rules) ~= "table" or #rules <= 0 then
        return false
    end

    for i, rule in ipairs(rules) do
        if rule.enable == true then
            -- judge阶段
            local pass = judge_util.judge_rule(rule, "rewrite")
            -- extract阶段
            local variables = extractor_util.extract_variables(rule.extractor)

            -- handle阶段
            if pass then
                local handle = rule.handle
                if handle and handle.uri_tmpl then
                    local to_rewrite = handle_util.build_uri(rule.extractor.type, handle.uri_tmpl, variables)
                    if to_rewrite and to_rewrite ~= ngx_var_uri then
                        if handle.log == true then
                            ngx.log(ngx.INFO, "[Rewrite] ", ngx_var_uri, " to:", to_rewrite)
                        end

                        local from, to, err = ngx_re_find(to_rewrite, "[%?]{1}", "jo")
                        if not err and from and from >= 1 then
                            --local qs = ngx_re_sub(to_rewrite, "[A-Z0-9a-z-_/]*[%?]{1}", "", "jo")
                            local qs = string_gsub(to_rewrite, from+1)
                            if qs then
                                local args = ngx_decode_args(qs, 0)
                                if args then 
                                    ngx_set_uri_args(args) 
                                end
                            end
                        end
                        ngx_set_uri(to_rewrite, true)
                    end
                end

                return true
            end
        end
    end

    return false
end




function RewriteHandler:rewrite(conf)
    RewriteHandler.super.rewrite(self)
    local enable = seassoon_db.get("rewrite.enable")
    local meta = seassoon_db.get_json("rewrite.meta")
    local selectors = seassoon_db.get_json("rewrite.selectors")
    local ordered_selectors = meta and meta.selectors
    if not enable or enable ~= true or not meta or not ordered_selectors then
        return
    end

    local ngx_var_uri = ngx.var.uri
    for i,sid in ipairs(ordered_selectors) do
        ngx.log(ngx.INFO,"==[Rewrite][PASS THROUGH SELECTOR:",sid,"]")

        local selector = selectors[sid]
        if selector and selector.enable then
            local seletor_pass 
            if selector.type == 0 then
                seletor_pass = true  -- 全流量选择器
            else
                seletor_pass = judge_util.judge_selector(selector,"rewrite") -- selector
            end
            if seletor_pass then
                if selector.handle and selector.handle.log  == true then
                    ngx.log(ngx.INFO,"[Rewrite][PASS-SELECTOR:",sid,"]",ngx_var_uri)
                end
                local stop = filter_rules(sid,"rewrite",ngx_var_uri)
                if stop then
                    return
                end

            else
                if selector.handle and selector.handle.log == true then
                    ngx.log(ngx.INFO,"[Rewrite][NOT-PASS-THROUGH:",sid,"]",ngx_var_uri)

                end

            end

            -- selector 有continue 字段 表示是否继续执行
            if selector.handle and selector.handle.continue == true then
                -- continue

            else
                break
            end
        end
    end
end

return RewriteHandler