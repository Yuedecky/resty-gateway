local _M ={}

local base_name = "base_app_name"
local base_version = "0.0.1" or {}
function _M._get_base_name()
    return base_name or ""
end

function _M._get_base_version( ... )
    return base_version
end