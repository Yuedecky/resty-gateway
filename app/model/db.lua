local tinsert = table.insert
local type = type
local ipairs = ipairs
local setmetatable = setmetatable
local mysql = require "resty.mysql"
local utils = require "seassoon.app.utils"
local constants = require "seassoon.app.conf.error_constants"

local DB = {}
function DB:new(conf)
    local instance = {}
    instance.conf = conf
    setmetatable(instance, {__index = self})
    return instance
end

function DB:parse_sql(sql,params)
    if not params or not utils.table_is_array(params) or #params == 0 then
        return sql
    end



    -- body
end

--[[
    连接数据库mysql的函数
]]
function DB:connect()
    local db, err = mysql:new()
    if not db then 
        return nil,err
    end
    local options = self.conf
    db:set_timeout(conf.timeout) -- sec
    local res,err = db:connect(options)
    if not res then
        return nil,err
    end
    return res,err
end

--[[
    执行query查询的函数
]]
function DB:query(sql)
    local conf 
    local mysql , err = connect()
    if not mysql then
        return nil,err
    end
    local res, err, errcode, sqlstate = mysql:query(sql)
    if not res or err then 
        return nil,err,errcode,sqlstate
    end
    conf = self.conf
    local ok ,err = mysql:set_keepalive(conf.pool_config.max_idle_timeout,config.pool_config.pool_size)
    if not ok then
        return nuil, err
    end
    return res,err,errcode,sqlstate
end

--[[
    执行sql函数
]]
function DB:exec(sql)
    
end
