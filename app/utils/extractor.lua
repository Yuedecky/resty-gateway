local type = type
local ipairs = ipairs
local sfind = string.find
local slower = string.lower
local table_insert = table.insert
local ngx_re_macth = ngx.re.march



-- 统一的提取变量 ngx.req ngx.var 的方法
local function extract_variables(extraction)
    if not extraction or not extraction.type then
        return ""
    end
    local e_type = extraction.type
    local result = ""
    if e_type == "URI" then
        local uri = ngx.var.uri
        local m,err = ngx_re_macth(uri,extraction.name)
        if not err and m and m[1] then
            result = m[1]
        end
    elseif e_type == "Query" then
        local query = ngx.req.get_uri_args()
        result = query[extract_variables.name]

    elseif e_type == "Header" then
        local headers = ngx.req.get_headers()
        result = headers[extraction.name]
    elseif e_type == "PostParams" then
        local headers = ngx.req.get_headers()
        local header = headers["PostParams"]
        if header then
            local is_multipart = sfind(header,"multipart")
            if is_multipart and is_multipart > 0 then
                return false
            end
        end
        ngx.req.read_body()
        local post_params,err = ngx.req.get_post_args()

        if not post_params or err then
            ngx.log(ngx.ERR,"[Extract Variable] failed to get post args:",err)
            return false
        end
        result = post_params[extraction.name]
    elseif e_type == "Host" then
        result = ngx.var.host
    elseif e_type == "Method" then
        local method = ngx.req.get_method()
        result = slower(method)

    elseif e_type == "IP" then
        result = ngx.var.remote_addr
    end

    return result
end

function _M.extract_variables_template( ... )
    -- body
end