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
        local kvstore_enable = "0"
        if enable then
            kvstore_enable = "1"
        end
        local update_result = store:update({
            sql = "replcae into meta SET `key` = ?,`value` = ?",
            params = {
                "kvstore.enable",
                kvstore_enable
            }
        })

        if update_result then
            seassoon_db:set("kvstore.enable",enable)
            res:json({
                success = true,
                msg = (enable == true and "开启kvstore成功" or "关闭kvstore成功")
            })
        else
            res:json({
                success = false,
                data = (enable == true and "开启kvstore失败" or "关闭kvstore失败")
            })
        end


    end
end)


API:get("/kvstore/fetch_config",function(store)
    return function(req,res,next)
        local data = {}
        local enable,err1 = store:query({
            sql = "select value from meta where `key` = ?",
            params = {"kvstore.enable"}
        })

        if err1 then
            return res:json({
                success = false,
                msg = "get kvstore enable error"
            })
        end
        if enable and type(enable) == "table" and #enable == 1 and enable[1].value == "1" then
            data.enable = true
        else
            data.enable = false
        end
        -- 查找其他配置
        local conf,err2 = store:query({
            sql = "select `value` from meta where `key`=?",
            params = {"kvstore.conf"}
        })
        if err2 then
            return res:json({
                success = false,
                msg = "get conf from meta err"
            })
        end

        if conf and type(conf) == "table" and #conf == 1 then
            data.conf = json.encode(conf[1].value)
        else
            data.conf = {}
        end

        res:json({
            success = true,
            data = data
        })

    end
end)

--[[
    同步kvstore
]]
API:post("kvstore/sync",function(store)

    return function(req,res,next)
        local data = {}

        local enable,err1 = store:query({
            sql ="select `value` from meta where `key` = ?",
            params={
                "kvstore.enable"
            }
        })

        if err1 then
            return res:json({
                success = false,
                msg = "get enable error"
            })
        end
        if enable and type(enable) == "table" then
            data.enable = true
        else
            data.enable = false
        end
        -- 查找其他配置，如 rules,conf等
        local conf ,err2 = store:queury({
            sql = "select `value` from meta where `key` = ?",
            params = {"kvstore.conf"}
        })

        if err2 then
            return res:json({
                success = false,
                msg = "get conf error"
            })
        end

        if conf and type(conf) == "table" and #conf == 1 then
            data.conf = json.decode(conf[1].value)
        else
            data.conf = {}
        end
        local ss,err3,forcible = seassoon_db:set("kvstore.enable",data.enable)
        if not ss or err3 then
            return res:json({
                success = false,
                msg = "update local enable error"
            })
        end
        ss,err3,forciable = seassoon_db:set_json("kvstore.conf",data.conf)
        if not ss or err3 then
            return res:json({
                success = false,
                msg = "update local conf error"
            })
        end
        res:json(
            {
                success = true,
                msg = "sync local kvstore success"
            }
        )
    end
end)


-- 查询kvstore的配置信息
API:get("/kvstore/config",function(store)

    return function(config)
        res:json({
            success = true,
            data = {
                enable = seassoon_db:get("kvstore.enable"),
                conf = seassoon_db:get_json("kvstore.conf")
            }
        })
    end
end)

API:post("/kvstore/configs",function(store)
    return function(req,res,next)
        local data,success = {},false
        local conf = req.body.conf
        -- 插入或者更新到mysql
        local update_result = store:query({
            sql = "replace into meta SET `key` = ?,`value` = ?",
            params = {
                "kvstore.conf",conf
            }
        })
        if update_result then
            local result,err,forcible = seassoon_db:set("kvstore.conf",conf)
            success = result
            if success then
                data.conf = json.decode(conf)
                data.enable = seassoon_db:get("kvstore.enable")
            end
        else 
            success = false
        end

        res:json({
            success = true,
            data = data
        })

    end
end)

API:put("/kvstore/configs",function(store)
    return function(req,res,next)
        local conf = req.body.conf
        local success,data = false ,{}
        --插入或者更新到mysql
        local update_result = store:update({
            sql = "replace into meta SET `key` = ?,`value`=?",
            params = {"kvstore.conf",conf}
        })

        if update_result then
            local result,err,forcible = seassoon_db:set("kvstore.conf",conf)

            success = result
            if success then
                data.conf = json.decode(conf)
                data.enable = seassoon_db.get("kvstore.enable")
            end
        else
            success = false
        end
        res:json({
            success = success,
            data = data
        })
    end
end)
