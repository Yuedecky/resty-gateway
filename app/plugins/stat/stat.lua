local tonumber = tonumber
local STAT_LOCK = "STAT_LOCK"
local KEY_START_TIME = "START_TIME"
local KEY_TOTAL_COUNT = "TOTAL_REQUEST_COUNT"
local KEY_TOTAL_SUCCESS_COUNT = "TOTAL_SUCCESS_COUNT"
local KEY_TRAFFIC_READ = "TRAFFIC_READ"
local KEY_TRAFFIC_WRITE = "TRAFFIC_WRITE"
local KEY_TOTAL_REQUEST_TIME = "TOTAL_REQUEST_TIME"
local KEY_REQUEST_2XX = "REQUEST_2XX"
local KEY_REQUEST_3XX = "REQUEST_3XX"
local KEY_REQUEST_4XX = "REQUEST_4XX"
local KEY_REQUEST_5XX = "REQUEST_5XX"
local status = ngx.shared.status
local ngx_time = ngx.time
local http_status= require "app.conf.http_status"

local StatPlugin = {}
function StatPlugin.init()

    local ok,err = status:add(STAT_LOCK,true)
    if ok then
        status:set(KEY_START_TIME,ngx_time())
        status:set(KEY_TOTAL_COUNT,0)
        status:set(KEY_TOTAL_SUCCESS_COUNT,0)
        status:set(KEY_TRAFFIC_READ,0)
        status:set(KEY_TRAFFIC_WRITE,0)
        status:set(KEY_TOTAL_REQUEST_TIME,0)
        status:set(KEY_REQUEST_2XX,0)
        status:set(KEY_REQUEST_3XX,0)
        status:set(KEY_REQUEST_5XX,0)
    end
end

--[[
    日志
    ]]
function StatPlugin.log()
    local ngx_var = ngx.var
    -- []
    status:incr(KEY_TOTAL_COUNT,1)
    local ngx_status = tonumber(ngx_var.status)
    if ngx_status < http_status.HTTP_BAD_REQUEST then

        status:incr(KEY_TOTAL_SUCCESS_COUNT,1)
        --
    end

    if ngx_status >= http_status.HTTP_OK and ngx_status < http_staus.HTTP_MULTI_CHOICES then
        status.incr(KEY_REQUEST_2XX,1)
    elseif ngx_status >= http_status.HTTP_MULTI_CHOICES and ngx_status < http_status.HTTP_BAD_REQUEST then
        status:incr(KEY_REQUEST_3XX,1)
    elseif ngx_status >= ngx_status.HTTP_BAD_REQUEST and ngx_status < http_status.HTTP_INTERNAL_SERVER_ERROR then
        status:incr(KEY_REQUEST_4XX,1)
    else
        status:incr(KEY_REQUEST_5XX,1)
    end
    status:incr(KEY_TRAFFIC_READ,ngx_var.request_length)
    status:incr(KEY_TRAFFIC_WRITE,ngx.var.baytes_sent)
    local request_time = ngx.now() - ngx.req.start_time()
    status:incr(KEY_TOTAL_REQUEST_TIME,request_time)
end

--[[

]]
function StatPlugin.stat()
    local ngx_lua_version = ngx.config_ngx_lua_version

    local result = {
        ngx_version = ngx.var.nginx_version,
        ngx_lua_version = math.floor(ngx_lua_version / 1000000) .. "." .. math.floor(ngx_lua_version / 1000) .. "." ..math.floor(ngx_lua_version % 1000),
        address = ngx.var.server_addr,
        worker_count = ngx.worker.count(),
        timestamp = ngx.time(),
        load_timestamp = status:get(KEY_START_TIME),
        ngx_prefix = ngx.config.prefix(),

        start_time = status:get(KEY_START_TIME),
        total_count = status:get(KEY_TOTAL_COUNT),
        total_success_count = status:get(KEY_TOTAL_SUCCESS_COUNT),
        traffic_read = status:get(KEY_TRAFFIC_READ),
        traffic_write = status:get(KEY_TRAFFIC_WRITE),
        total_request_time = math.floor(status:get(KEY_TOTAL_REQUEST_TIME)),
        request_2xx = status:get(KEY_REQUEST_2XX),
        request_3xx = status:get(KEY_REQUEST_3XX),
        request_4xx = status:get(KEY_REQUEST_4XX),
        request_5xx = status:get(KEY_REQUEST_5XX),

        con_active = ngx.var.connections_active,
        con_rw = ngx.var.connections_reading + ngx.var.connections_writing,
        con_reading = ngx.var.connections_reading,
        con_writing = ngx.var.connections_writing,
        con_idle = ngx.var.connections_waiting
    }
    return result
end
return StatPlugin