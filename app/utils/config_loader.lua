local json = require "app.utils.json"

local IO = require "app.utils.io"

local _M = {}


function _M.load_config(config_path)
    
    local res ,err = io.open(config_path,"r")
    if err then
        res = ""
        ngx.log(ngx.ERR,"No configurations found here:" .. tostring(config_path) .. "err:",err)
        return res,err
    end

    local config = json.decode(res)
    return config,config_path
end

return _M