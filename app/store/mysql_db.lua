local tinset = table.insert
local type = type
local ipairs = ipairs
local setmetatable = setmetatable
local mysql = require "resty.mysql"
local utils = require("app.utils.utils")
local DB = {}

-- 初始化数据库连接
function DB:new(conf)
    local instance = {}
    instance.conf = conf
    setmetatable(instance,{__index = self})
    return instance
end

-- 执行sql脚本的函数 
function DB:exec(sql)

    local conf = self.conf
    local db,err = mysql:new()
    if not db then
        ngx.log(ngx.ERR,"failed to instantiate mysql",err)
        return
    end
    db:set_timeout(conf.timeout) -- 1 sec
    local ok ,err ,errno,sqlstate = db:connect(conf.connect_config) 

    if not ok then
        ngx.log(ngx.ERR,"failed to connect :",err,":",errno,"",sqlstate)
        return
    end
    ngx.log(ngx.INFO,"connected to mysql,reused_times:",db:get_reused_times(),"sql:",sql)
    db:query("SET NAMES utf8")
    local res,err,sqlstate = db:query(sql)
    if not res or err then
        ngx.log(ngx.ERR,"bad result:",err,": ",errno,": ",sqlstate,".")
    end

    local ok , err = db:set_keepalive(conf.pool_config.max_idle_timeout,conf.pool_config.pool_size)

    if not ok then
        ngx.log(ngx.ERR,"failed to set keepalive:",err)
    end
    return res,err,errno,sqlstate
end

-- 查询方法
function DB:query(sql)

    sql = self:parse_sql(sql,params)
    return self:exec(sql)
end
-- 插入数据的方法
function DB:insert(sql,params)
    local res,err,errno,slqstate = self:query(sql,params)

    if res and not err then
        return res.insert_id ,err
    else
        return res,err
    end
end

-- update
function DB:update(sql,params)
    return self:query(sql,params)
end

-- 删除操作
function _M:delete(sql,params)
    local res,err,errno , slqstate = self:query(sql,params)
    if res and not err then
        return res.affected_rows,err
    else
        return res,err
    end
end

local function split(str,delimiter)
    if str == nil or str == "" or delimiter == nil then
        return nil
    end
    local result = {}
    for match in (str .. delimiter):gmatch("(.-)"..delimiter) do
        tinset(result,match)
    end
    return result
end

local function compose(t,params)
    if  t == nil or params == nil or type(t) ~= "table" or #t ~= #params + 1 or #t == 0 then 
        return nil
    else 
        local result = t[1]
        for i = 1,#params do 
            result = result .. params[i] .. t[i+1]
        end
        return result
    end
end
--解析sql的方法
function DB:parse_sql(sql,params)
    if not params or not utils.table_is_array(params) then
        return sql

    end
    local new_params = {}
    for i,v in ipairs(params) do
        if type(v)  == "string"  then
            v = ngx_quote_sql_var(v)
        end
        tinset(new_params,v)
    end

    local t = sp
end