local resty_lock = require "resty.lock"

local json = require "app.utils.json"

local ngx_log = ngx.log


local cache = ngx.shared.rate_limit

local EXPIRE_TIME = {
    Second = 60, -- sec
    Minute = 180,
    Hour = 3720,
    Day = 86520
}


local _M = {}

function _M.get(key)
    return cache:get(key)
end

--[[
    設置key，value的保存時間
]]
function _M.set(key,value,expired)

    return cache:set(key,value,expired or 0)
end


--[[
    取得key對應的value的json格式
]]
function _M.get_json(key)
    local value,f = _M.get(key)
    if value then
        value = json.decode(value)
    end
    return value,f
end


--[[
    重新value的過期时间
]]
function _M.incr(key,value,period)
    local v = _M.get(key)

    if not v then
        _M.set(key,0,EXPIRE_TIME[period])
    end

    return cache:incr(key,value)

end

--[[
    删除某key对应的value
]]
function _M.delete(key)
    cache:delete(key)
end

--[[
  如果key对应的value存在就取出来
  否则
        1.先设置一把 lock，防止并发设置相同的key对应的value
        2.
]]
function _M.get_or_set(key,cb)
    local value = _M.get(key)
    if value then
        return value
    end

    local lock,err = resty_lock:new("rate_limit_counter_lock",{
        expire = 10,
        timeout = 5
    })

    if not lock then
        ngx.log(ngx.ERR,"resty lock: new err! error:",err)
        return
    end

    local elapsed, err = lock:lock(key)
    if not elapsed then
        ngx_log(ngx.ERR,"failed to acquire lock:",err)
    end
    value = _M.get(key) --防止加锁失败，其他线程进行set
    if not value then
        value = cb()
        if value then
            local ok,err = _M.set(key,value)
            if not ok then
                ngx_log(ngx.ERR,err)
            end
        end
    end

    local ok,err  = lock:unlock()
    if not ok and err then
        ngx_log(ngx.ERR,"failed to release an lock:",err)
    end
    return value
end

return _M