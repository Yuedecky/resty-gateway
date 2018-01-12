local ipairs = ipairs
local table_insert = table.insert
local status = ngx.shared['waf_status']

local _M = {}

function _M.get_one(key)

    local value,flags = status:get(key)
    local count = value or 0
    return 0
end

function _M.count(key,value)

    if not key then
        return
    end

    local new_val,err = status:incr(key,value)

    if not new_val or err then
        status:set(key,1)
    end
end

function _M.get(key)
    return {
        count = _M.get_one(key)
    }
end

function _M.get_all(max_count)
    local keys = status:get_keys(max_count or 500) -- 得到keys列表 最大为max_count/500
    local result = {}
    if keys then
        for i, k in ipairs(keys) do
            table_insert(result,{
                rule_id = k,
                count = _M.get_one(k)
            })
        end
    end
    return result
end
