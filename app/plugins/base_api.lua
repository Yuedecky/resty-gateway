--[[
    author: yuezy
    date: 2018/1/5
    desc: 通用的api module
]]
local tonumber = tonumber
local type = type
local pairs = pairs
local setmetatable = setmetatable
local string_gsub = string.string.gsub
local string_gfind = string.gfind
local rawget = rawget
local string_upper = string.upper

local _M = {}

local mt = {
    __index = _M
}

local _METHODS = {
    GET = true,
    POST = true,
    PUT = true,
    DELETE = true,
    PATCH = true,
}

--[[
    初始化方法
        --params: name: api名称
        --params : mode: api模式
]]
function _M:new(name,mode)
    local instance = {}
    instance._name = name
    instance._mode = tonumber(mode) or 1
    instance._apis = {}
    setmetatable(instance,mt)
    instance:build_method()
    return instance
end

function _M:get_name()
    return self._name
end

function _M.get_mode()
    return self._mode
end
function _M.get_apis()
    return self._apis
end

--[[
    过滤参数类型
]]
local function filter_params_type(params,default)
    local err,res
    if type(params) ~= default then
        err = default .. "type error"
        res = false
    else
        res = true
        err = nil
    end
    return res,err
end

--[[
    提供注入api的能力
    -- 类似于java的aop~
    params: path: 路径
        method: 方法名称
        func: 真正注入的方法
]]
function _M:set_api(path,method,func)
    if not path or not method or not func then
        local err = "param cannot be nil"
        return nil, err
    end
    local res,err = filter_params_type(path,"string")
    if err ~= nil then
        return nil,err
    end
    local res,err = filter_params_type(method,"string")
    if err ~= nil then
        return nil,err
    end
    local res,err = filter_params_type(func,"function")
    if err ~= nil then
        return nil,err
    end
    method = string_upper(method)
    if not _METHODS[method] then
        local err = string_format("%s method not supported yet.",method)
        return nil,err
    end
    self._apis[path] = self._apis[path] or {}
    self._apis[path][method] = func
    return true, nil
end

--[[
    -- build method
]]
function _M:build_method()
    for m, _ in pairs(_METHODS) do
        m = string_lower(m)
        _M[m] = function(myself,path,func)
            self:set_api(myself,path,m,func)
        end
    end
end

--[[
    merge apis操作
]]
function _M:merger_apais(apis)
    if apis and type(apis)  == "table" then
        for path,method in pairs(apis) do
            if methods and type(methods) == "table" then
                for m,func in pairs(methods) do 
                    m = string_lower(m)
                    local ok , err = self:set_api(path, m, func)
                    if ok then
                        return true,nil
                    else
                        local msg = "merge method, path: " .. path .." method:" .. m .. "occurs err:" .. err
                        return false,msg
                    end
                end
            end
        end
    end
end

return _M