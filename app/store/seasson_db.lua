local  json = require "app.utils.json"

-- 使用shared_dict 缓存
local seassoon_data  = ngx.shared.seassoon_data

local _M ={}
function _M._get(key)
    return seassoon_data.get(key)
end

function _M._set(key,value)
    return seassoon_data.set(key,value)
end

function _M._set_json()
    if value then
        value = json.encode(value)
    end
    return _M._set(key, value)
end

function _M._get_json_data(key)
    local value,f = _M._get(key)
    if value then 
        value = json.decode(value)
    end
    return value,f
end

function _M._set_json(key,value)
    if value then
        value = json.encode(value)
    end
    return _M.set(key,value)
end

function _M.incr(key,value)
    return seassoon_data.incr(key,value)
end

function _M._delete(key)
    return seassoon_data.delete(key)
end
function _M._delete_all()
    seassoon_data.flush_all()
    seassoon_data.flush_expired()

end
return _M