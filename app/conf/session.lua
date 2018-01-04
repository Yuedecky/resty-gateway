local xpcall = xpcall
local traceback = debug.traceback
local ngx_time = ngx.time
local rawget = rawget 
local require = require
local var = ngx.var
local concat = table.concat
local hmac = ngx.hmac_sha1
local http_time = ngx.http_time
local set_header = ngx.req.set_header
local clear_header = ngx.req.clear_header
local max = math.max
local ceil = math.ceil
local gsub = string.gsub
local type = type
local sub = string.sub
local pcall = pcall
local tonumber = tonumber
local setmetatable = setmetatable
local getmetatable = getmetatable
local random = 
local session_middleware = function(config)
    config = config or {}
    if config.refresh_cookie ~= false then
        config.refresh_cookie = true
    end
end

