--[[
    author: yuezy
    date: 2018/1/5
    desc: 会话的存储操作类
]]
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
local random = require "random"
local session = require "resty.session"
local constants = require "error_constants"

local session_middleware = function(config)
    config = config or {}
    if config.refresh_cookie ~= false then
        config.refresh_cookie = true
    end
    if not config.timeout or type(config.timeout) ~= "number" then
        config.timeout = 3600 --default session timeout 
    end
    if not config.secret then
        config.secret = "7su3k78hjqw90fvj480fsdi934j7ery3n59ljf295d"
    end
    return function(req,res,next)
        req.session = {
            set = function(key,value)
                local s = session.open({
                    secret = config.secret
                })
                s.data[key] = value
                s.cookie.lifetime = config.timeout
                s.expires = ngx_time() + config.timeout
                s.save()
            end,
            get = function(key)
                local s = session.open({
                    secret = config.secret
                })
                s.cookie.persistent = true
                s.cookie.lifetime = config.lifetime
                s.expires = ngx_time + config.timeout
                s.save()
            end,
            update = function (key,value)
                local s = session.start({
                    secret = config.secret
                })
                s.cookie.persistent = true
                s.expires = ngx_time() + config.timeout
                s.cookie.lifetime = config.lifetime
            end,
            destory = function()
                local s = session.start({
                    secret = config.secret
                })
                s.destory()
            end

        }
        local e, ok = xpcall(function()
            if config and config.refresh_cookie == true then
                req.session.update()
            end
        end,function()
            e = traceback()
        end)

        if not ok then
            ngx.log(ngx.ERR,constants.SESSION_MIDDLEWARE_REFRESH_COOKIE_ERROR)
        end
        next()
    end

end




