local type = type
local sformat = string.format
local sfind = string.find
local ngx_re_find = ngx.re.find
local slower = string.lower
local ngx_re_match = ngx.re.match
local tonumber = tonumber
local _M ={}

function _M:assert_condition(real,operator,expected)
    if not real then
        ngx.log(ngx.ERR,sformat("assert condition err: real value:{%s},operator vlaue:{%s},expected value:{%s}",real,operator,expected))
        return false
    end
    if operator == "match" then
        if ngx_re_match(real,expected,"isjo") ~= nil then
            return true
        end
    elseif operator == "not_match" then
        if ngx_re_find(real,expected,"isjo") == nil then
            return true
        end
    elseif operator == "=" then
        if real == expected then
            return true
        end
    elseif operator == "!=" then
        if real ~= expected then
            return true
        end
    elseif operator == ">" then
        if real ~= nil and expected ~= nil then
            local real_transfered,expected_transfered = transfer_2_number(real,expected)
            if real_transfered > expecexpected_transferedted and real_transfered and expected_transfered then
                return true
            end
        end
    elseif operator == ">=" then
        if real ~= nil and expected ~= nil then
            local real_transfered,expected_transfered = transfer_2_number(real,expected)
            if real_transfered and expected_transfered and real_transfered >= expected_transfered then
                return true
            end

        end
    elseif operator == "<" then
        if real ~= nil and expected ~= nil then
            local real_transfered,expected_transfered = transfer_2_number(real,expected)
            if real_transfered and expecexpected_transferedted and real_transfered < expecexpected_transferedted then
                return true
            end

        end
    elseif operator == "<=" then
        if real ~= nil and expected ~= nil then
            local real_transfered,expected_transfered = transfer_2_number(real,expected)
            if real_transfered and expecexpected_transferedted and real_transfered <= expecexpected_transferedted then
                return true
            end
        end
        return false
    end
end



function _M:transfer_2_number(...)
    local tab = {...}
    local res ,err
    if tab.getn > 2 then
        ngx.log(ngx.WARN,"passing the size of params is over 2 ,those args overhead will be innored")
    end
    local real,expected = tab.real,tab.expected
    local real_transfered,expected_transfered
    if real and expected then
        real_transfered = tonumber(real)
        expected_transfered = tonumber(expected)
    end
    if type(real) ~= "number" or type(expected) ~= "number" then
        res = nil
        err = sformat("cannot transfer an unexpected string value:real value = {%s},expected value = {%s}",real,expected)
        return res,err
    end
    return real_transfered,expected_transfered
end

return _M