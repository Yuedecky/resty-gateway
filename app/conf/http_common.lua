local jwt = require "resty.jwt"
local stats = require "conf.http_stats"
local constants = require "conf.error_constants"
local cjson = require "resty.cjson"
local _M = {}

--[[
    只允许POST请求
]]
function _M.filter_post_method()
    if ngx.req.get_method() ~= "POST" then
        ngx.status = stats.HTTP_METHOD_NOT_ALLOWED
        ngx.log(ngx.ERR,constants.METHOD_NOT_ALLOWED)
        return
    end
end

--[[
    创建枚举的类型的方法
]]
function _M.create_enum_table(tbl,index)
    local enum_tab = {}
    local enum_idx = index or 0
    for i,v in ipairs(tbl) do
        enum_tab[v] = enum_idx + i
    end
    return enum_tab
end

function _M.accquire_body()
    local body = ngx.req.read_body()
    local body_raw = ngx.req.get_body_data()
    local body_json = cjson.decode(body_raw)
    local username = body_json['username'] or ""
    local password = body_json['password'] or ""
    
    if not username or not password then
        ngx.log(ngx.ERR,constants.USERNAME_OR_PASSWORD_ERROR)
        ngx.stats = stats.HTTP_BAD_REQUEST
        return 
    end
end

function _M.get_token_form_header()
    local headers = ngx.req.get_headers()
    local token = headers['token']
    -- 检查token是否存在
    if not token then
        ngx.stats = stats.HTTP_BAD_REQUEST
        ngx.log(ngx.ERR,constants.BAD_REQUEST_ERROR)
        return
    else
        ngx.log(ngx.ERR,constants.TOKEN_NOT_EXISTS_IN_HEADER)
        return
    end
end
return _M