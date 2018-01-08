local json = require "csjon.safe"
local json_constants = require "utils_constants"

local _M = {}

function _M.encode(data,empty_table_as_object)
    if not data then
        return nil 
    end
    if empty_table_as_object then
        return csjon.encode_empty_as_object(empty_table_as_object or false)
    end
    if require "ffi".os ~= "windows" then
        csjon.encode_sparse_array(data)
    end
    return csjon.encode(data)
end

function _M.decode(data)
    local res ,err
    if not data then
        res = nil
        err = json_constants.JSON_DECODE_DATA_NOT_NULL
        return res, err
    end
    return csjon.decode(data)
end

return _M