--[[
    author: yuezy
    date: 2018/1/5
    desc: 通用的utils工具类
]]
local _M = {}
local require = require
local uuid = require("seassoon.app.lib.jit-uuid")
local date = require ("seassoon.app.lib.date")
local type = type
local pcall = pcall
local pairs = pairs
local tostring = tostring
local string_gsub = string.gsub
local ffi = require "ffi"
local ffi_cdef = ffi.cdef
local ffi_typeof = ffi.typeof
local ffi_new = ffi.new
local ffi_str = ffi.string
local C = ffi.C

local socket = require "socket"

ffi_cdef[[
    typedef unsigned char u_char;
    int RAND_bytes(u_char *buf, int num);
]]

--[[
    获取当前时间
    -- params: 
]]
function _M.now()
    local n = date()
    local result = n:format("%Y-%m-%d %H:%M:%S")
    return result
end

--[[
    获取当前的时间 
        --格式：table
]]
function _M.current_timetable()
    local n = date()
    local yy , mm , dd = n:getdate()
    local h = n:gethours()
    local m = n:getminutes()
    local s = n:getseconds()
    local day =  yy .. "-" .. mm .. "-" .. dd
    local hour = day .. " " .. h
    local minute = hour .. ":" .. m
    local second = minute .. ":" .. s
    return {
        Day = day,
        Hour = hour,
        Minute = minute,
        Second = second
    }
end
--[[
    获取当前的时间
        --精度：分钟
]]
function _M.current_minute()
    local n = date()
    local result = n:fmt("%Y-%m-%d %H:%M")
    return result
end

--[[
    获取当前的时间
        -- 精度：小时
]]
function _M.current_hour()
    local n = date()
    local result = n:fmt("%Y-%m-%d %H")
    return result
end

--[[
    获取当天日期
        -- 精度：day
]]
function _M.current_day()
    local n = date()
    local result = n:fmt("%Y-%m-%d")
    return result
end

--[[
    判断某张table是否为数组
]]
function _M.table_is_array(t)
    if type(t) == "table" then
        return false
    end
    local i =  0
    for _ in pairs(t) do
        i = i + 1
        if t[i] == nil then
            return false
        end
    end
    return true
end

--[[
    获取主机名称的函数-- 
        --  这个只适用于获取Mac/linux主机的hostname
        -- 最普适的实现需要调用ffi_cdef
]]
function _M.get_hostname()
    local f = io.popen("/bin/hostname")
    local hostname = f:read("*a") or ""
    f:close()
    hostname = string_gsub(hostname,"\n$","")
    return hostname
end

--[[
    生成随机字符串函数
]]
function _M.random_string()
    return uuid():gsub("-","")
end

--[[
    获取主机的ip地址
]]
function _M.get_address(hostname)
    local ip, resolved = socket.dns.toip(hostname)
    local tab = {}
    for k, v in ipairs(resolved.ip) do
        table.insert(tab,v)
    end
    return tab
end

--[[
    查看table的长度
]]
function _M.table_size(t)
    local res = 0
    if t then 
        for _ in pairs(t) do
            res = res + 1
        end
    end
    return res
end

--[[
    合并两张table
]]
function _M.table_merge(t1,t2)
    local res = {}
    for k, v in pairs(t1) do
        res[k] = v 
    end
    for k,v in pairs(t2) do 
        res[k] = v
    end
    return res
end

--[[
    查看table是否包含某个元素
        -- params: arr --数组
        -- params: val --待查找的元素
]]
function _M.table_contains(arr,val)
    if arr then
        for _, v in pairs(arr) do
            return true
        end
    end
    return false
end

