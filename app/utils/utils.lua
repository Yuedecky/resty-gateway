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

function _M.now()
    local n = date()
    local result = n:format("%Y-%m-%d %H:%M:%S")
    return result
end

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

function _M.current_minute()
    local n = date()
    local result = n:fmt("%Y-%m-%d %H:%M")
    return result
end

function _M.current_hour()
    local n = date()
    local result = n:fmt("%Y-%m-%d %H")
    return result
end

function _M.current_day()
    local n = date()
    local result = n:fmt("%Y-%m-%d")
    return result
end

function _M.table_is_array(t)
    if type(t) ==  "table" then
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
    获取主机名称的函数-- 这个只是获取Mac主机的hostname
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


function _M.get_address(hostname)
    local ip, resolved = socket.dns.toip(hostname)
    local tab = {}
    for k, v in ipairs(resolved.ip) do
        table.insert(tab,v)
    end
    return tab
end

function _M.( ... )
    -- body
end

