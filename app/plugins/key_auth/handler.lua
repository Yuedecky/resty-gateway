local ipairs = ipairs
local type = type
local sfind = string.find
local auth_type = require "app.plugins.key_auth.credential_type"
local utils = require "app.utils.utils"

local app_db = require "app.store.seasson_db"

local judge_util = require "app.utils.judge"

local handle_util = require "app.utils.handle"

-- 判断请求头是否需要 认证
local function is_credential_in_header(headers,key,target_value)
    if not headers or not key or not target_value then 
        return false
    end
    if headers[key] == target_value then
        return true
    end
    return false
end


-- 检查查询是否包含 认证
local function is_credential_in_query(query,key,target_value )
    if not query or not key or not target_value then
        return false
    end
    
    if type(query) ~= "table" or type(key) ~= "string"  then
        return false
    end
    if key == "" then 
        return false
    end
    if query[key] == target_value  then
        return true
    end
    return false
end

local function is_credential_in_body(body,key,target_value)
    if not body or not target_value or not key then
        return false
    end
    if type(body) ~= "table" or type(key) ~= "string" then
        return false
    end
    if key == "" then
        return false
    end
    if body[key] == target_value then 
        return true
    end
    return false
end


local  function is_authorized(credentials,header,query,body)
    if not credentials then
        return false
    end
    local auth = false

    for j, v in ipairs(credentials) do
        local key = v.key
        local target_value = v.target_value
        local credential_type = tonumber(v.type)
        if credential_type  == auth_type.HEADER_AUTH_TYPE then
            if is_credential_in_header(header,key,target_value) then
                auth = true
                break
            end
        elseif credential_type == auth_type.QUERY_AUTH_TYPE then
            if is_credential_in_query(query,key,target_value) then
                auth = true
                break
            end
        elseif credential_type == auth_type.BODY_AUTH_TYPE then
            if is_credential_in_body(body,key,target_value) then
                auth = true
                break
            end
        end
    end
    return auth
end

function get_body(content_type)
    if content_type and type(content_type) == "string" then
        local is_multipart = sfind(content_type,"multipart")
        if is_multipart and is_multipart > 0 then
            return nil
        end
    end

    local body 

    ngx.req.read_body()
    local post_args = ngx.req.get_post_args()
    if post_args and type(post_args) == "table" then
        for k,v in ipairs(post_args) do

            body = {}
            body[k] = _v
        end
    end
    return body
end

local function filter_rules(sid,plugin,ngx_var_uri,headers,body,query)

    local rules = seasson_db.get_json(plugin .. ".selector" .. sid ..  ".rules")
    if not rules or type(rules) ~= "table" or #rules <= 0 then
        return false
    end
    for i,rule in ipairs(rules) do
        local enable  = rule.enable
        if enable == true then

        end
    end
    
    -- body
end