local red = require "resty.redis"
local config = require "config"
local setmetatable = setmetatable

local tonumber = tonumber
local concat = table.concat
local floor = math.floor
local sleep = ngx.sleep
local null = ngx.null
local now = ngx.now
local var = ngx.var


local function enabled(args)
    if args == nil then
        return false
    else
        return args == "true" or args == "on" or args == "ok" or tonumber(args) == 1
    -- body
end
local default = {
    prefix = var.session_redis_prefix or config.redis.session_prefix,
    socket = var.session_redis_socket ,
    host = var.session_redis_host or config.redis.host,
    port = tonumber(var.session_redis_port) or config.redis.port,
    auth = var.session_redis_auth,
    uselock = enabled(var.session_resdis_uselock) or config.redis.uselock,
    spinlockwait = tonumber(var.session_redis_spinlock) or config.redis.spinlockwait,
    auth = config.redis.auth or true,
    maxlockwait = tonumber(var.redis.maxlockwait) or config.redis.maxlockwait,
    pool = {
        timeout = tonumber(var.session_redis_pool_timeout) or config.redis.pool['timeout'],
        poolsize = tonumber(var.session_redis_pool_size) or config.redis.pool['size']
    }
}

local redis = {}


