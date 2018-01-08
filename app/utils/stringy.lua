local string_gsub = string.gsub

local sfind = string.find

local table_insert = table.insert

local _M = {
    __VERSION = "0.0.1"
}

-- 截取所有的 空格 方法
function _M.trim_all(str)
    if not str or str == "" then 
        return ""
    end
    local result = (string.gsub(s, "^%s*(.-)%s*$", "%1"))
    return result
end

function _M._strip(str)
    if not str or str == "" then
        return ""
    end
    local result = string_gsub(str,"^ *","")
    result = string_gsub(result,"( *)$","")
    return result
end

-- 字符串分割
function _M.split(str, delimiter)
    if not str or str == "" then return {} end
    if not delimiter or delimiter == "" then return { str } end

    local result = {}
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        table_insert(result, match)
    end
    return result
end

-- 字符串是否以某个 子串开始的 判断方法
function _M.starts_with(str,substr)

    if str == nil or substr == nil  then
        return false
    end
    if sfind(str,substr) ~= 1 then
        return false
    else
        return true
    end
end

-- 字符串是否以 某个子串结束的 方法
function _M.ends_with(str,substr)
    if str == nil or substr == nil then
        return false
    end
    local str_reverse = string.reverse( str )
    local sub_str_reserve = string.reverse(substr)
    if string.find(str_reverse,sub_str_reserve) ~= 1 then
        return false
    else
        return true
    end

end

return _M