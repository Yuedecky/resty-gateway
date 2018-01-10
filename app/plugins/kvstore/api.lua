local ipairs = ipairs

local type = type
local tostring = tostring

local sformat = string.format

local stringx = require "pl.stringx"

local traceback = debug.traceback
local status = require ""
local json  = require "app.utils.json"

local status = require "app.conf.http_status"
local rformat= require "return_format"

local BaseAPI = require("app.plugins.base_api")
    
--[[
send_err_result 发送错误请求
]]
local function send_err_result(res,format,err )
  send_status_format_result(res,status.HTTP_INTERNAL_SERVER_ERROR,format,err)
end

local function send_failed_result(res,format,err)
    send_status_format_result(res,status.HTTP_OK,format,err)
end

--[[


]]
local function send_success_result(res,format)
    send_status_format_result(res,status.HTTP_OK,format,"success")
end

local function send_status_format_result(res,status,format,err)
    if status >= status.HTTP_BAD_REQUEST then
        if format == rformat.APPLICATION_TYPE_JSON then
            res:status(status):json({
                success = false,
                err = err
            })  
        elseif format == rformat.APPLICATION_TYPE_HTML then
            res:status(status):html(err)
        elseif format == rformat.APPLICATION_TYPE_TEXT then
            res:status(status).send(err)
        end
    else
        if format == rformat.APPLICATION_TYPE_JSON then
            res:json({
                    success = false,
                    err = err
                })
        elseif format == rformat.APPLICATION_TYPE_HTML then
            res:html(err)
        elseif format == rformat.APPLICATION_TYPE_TEXT then
            res:send(err)
        end
    end
end

--[[


]]
local function send_result(res,format,value)
    if format == rformat.APPLICATION_TYPE_JSON then
        xpcall(function ()
            value = json.decode(value)
        end,function(err)
            local trace =traceback(err,2)
            ngx.log(ngx.ERR,"decode as json err:",err)
        end)
        res:json({
            success = true,
            data = value
        })
    elseif format == rformat.APPLICATION_TYPE_TEXT then
        res:send(value or "")
    elseif format == rformat.APPLICATION_TYPE_HTML then
        res:html(value or "")
    end
end

local API = BaseAPI:new("kvstore",2)

API:post("/kvstore/enable",function(store)
    return function (res,req,next)
        local enable = req.body.enable
        if enable == "1" then
            enable = true
        else 
            enable = false
        end
        local result = false


    end
end)


