local ipairs =ipairs

local base = require("app.base.base")

local table_insert = table.insert
local table_concat = table.concat

local type = type
local xpcall = xpcall

local json  = require("app.utils.json")
local seassoon_db = require "app.store.seassoon_db"

local _M  = {
    __VERSION = base.__VERSION,
    desc = "store dao & local cache",
}

function _M._get_selector(plugin,store,selector_id)
    if not selector_id or selector_id == "" or type(selector_id) ~= "string" then
        return nil
    end
    local selector,err = store:query({
        sql = "select * from " .. plugin .."where `key` = ? and `type` = ? limit 1 ",
        params  = {
            selector_id,"selector"
        }
    })

    if not err and selector and type(selector) == "table" and #selector > 0 then
        return selector[1]
    end
    return nil

end

function _M._get_rules_of_selector(plugins,store,rule_ids)
    if not rule_ids or type(rule_ids) ~= "table" or #rule_ids ==  0 then
        return {}
    
    end
    local to_connect   = {}
    for _,r in ipairs(rule_ids) do
        table_insert(to_connect,"'" .. r .. "'")

    end
    local to_get_rule_ids =table_concat(to_connect,",")

    if not to_get_rule_ids or to_get_rule_ids == "" then
        return {}
    end
    local rules,err = store.query({
        sql = "select * from " .. plugins .. "where `key` in (" .. to_get_rule_ids .. ") and type = ?",
        params = {
            "rule"
        }

    })
    if err then 
        ngx.log(ngx.ERR,"err to get rules of selector,err:",err)
        return {}
    end
    if rules and type(rules) == "table" and #rules > 0 then
        local format_table = {

        }
        for _, rule_id in ipairs(rule_ids) do
            for _, r in  ipairs(rules) do
                local tmp = json.decode(r.value)
                if tmp and tmp.id == rule_id then 
                    table_insert(format_table,tmp)
                end
            end
        end
        return format_table
    else
        return {}
    end
end

function _M.delete_rules_of_selector(plugin,store,rule_ids)
    if not rule_ids or rule_ids == "" or type(rule_ids) ~= table then
        return true
    end
    local to_concat = {}
    for _ ,rule_id in ipairs(rule_ids) do
        table_insert(to_concat, "'" .. rule_id .. "'")
    end
    local to_delete_rule_ids = table_concat(to_concat,",")
    if not to_delete_rule_ids or to_delete_rule_ids == "" then
        return true
    end

    local delete_result = store:delete({
        sql = "delete from " .. plugin .. "where `key` in (" .. to_delete_rule_ids .. ") and `type` = ?",
        params = {
            "rule"
        } 
    })
    if delete_result then
        return true
    else
        ngx.log(ngx.ERR,"delete rules of store err:",err)
        return false
    end

end

function _M._delete_seletor(plugin,store,selector_id)
    if not selector_id or selector_id == "" or #selector_id == 0 then
        return false
    end
    local delete_result = store:delete({
        sql = "delete from " .. plugin .."where `key`  = ? and `type` = ?" ,
        params = {
            selector_id,"selector"
        }

    })
    if delete_result then 
        return true
    else
        ngx.log(ngx.ERR,"delete store err:",err)
        return false
    end
end

function _M.get_meta(plugin,store)
    local meta,err = store:query({
        sql = "select * from " .. plugin .. "where `key` = ? and `type` = ?",
        params = {
            "meta"
        }
    })
    if err then
         ngx.log(ngx.ERR,"[FATAL ERROE] meta not found while it must exists")
         return nil
    else
        return meta[1]
    end
end

function _M._update_meta(plugin,store,meta)
    if not meta or type(meta) ~= "table" then
        return false
    end
    local meta_json_str = json.encode(meta)
    
    if not meta_json_str then 
        ngx.log(ngx.ERR,"encode err:meta to save is not json format")
        return false
    end

    local result = store:update({
        sql  = "update " .. plugin .. "set `value` = ?  where `type` = ?",
        params = {
            meta_json_str, "meta"
        }
    })
    return result
end


function _M.update_selector(plugin,store,selector)
    if not seletor or type(selector) ~= "table" then
        return false
    end
    local selector_json_str = json:encode(selector)
    if not selector_json_str or selector_json_str == "" then 
        ngx.log(ngx.ERR, "encode error: selector to save is not json format.")
        return false
    end
    local result = store:update({
        sql = "update" .. plugin .. "set where `key` = ? and `value` = ? and `type` = ?" ,
        params = {
            selector_id,selector_json_str,"selector"
        }
    })
    return result
end


function _M.update_local_meta(plugin,store)
    local meta,err = store:query({
        sql = "select * from " .. plugin .. "where `type` = ? limit 1",
        params = {
            "meta"
        }
    })
    if err then 
        ngx.log(ngx.ERR,"err to find meta from storage when update local meta,err:",err)
        return false
    end
    if meta and type(meta) == "table" and #meta >0 then
        local success,err ,forcible = seaassoon_db.set(plugin .. ".meta",meta[1].value or "{}")
        if err or not success then
            ngx.log(ngx.ERR,"update local plugin's meta err:",err)
            return false
        end
    else
        ngx.log(ngx.ERR,"can not find meta from storage when updating local meta")
        return false
    end
    return true
end

function _M.update_local_seletors(plugin,store)
    local selectors,err = store:query({
        sql = "select * from " .. plugin .. "where `type` = ?",
        params ={
            "selector"
        }
    })

    if err then
        ngx.log(ngx.ERR,"error to find selectors from storage when updating local storage,err:",err)
        return false
    end

    local to_update_selectors = {}
    if selectors and type(selectors) == "table" then
        for _ , s in ipairs(selectors) do
            to_update_selectors[s.key] = json.decode(s.value or "{}")
        end

        local success , err ,forcible = seassoon_db:set_json(plugin .. ".selectors",to_update_selectors)
        if err or not success then
            ngx.log(ngx.ERR,"update local plguin's selectors err:",err)
            return false
        end
    else
        ngx.log(ngx.ERR,"the size of selectors from storage is 0 when updating local selectors")
        local success,err,forcible = seassoon_db:set_json(plugin .. ".selectors",{})
        if err or not success then
            ngx.log(ngx.ERR,"update local plugin's selectors error,err:",err)
            return false
        end
    end
    return true
end

function _M.update_local_selector_rules(plugin,store,selector_id)
    if not selector_id or selector_id == "" or #selector_id ==0 then
        return false
    end

end