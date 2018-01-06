local type = type
local tonumber = tonumber
local ngx_md5 = ngx.md5
local string_gsub = string.gsub
local template = require "resty.template"

template.print = function (s)
    return s
end

local function compose(extractor_type,tmpl,variables)
    if not tmpl then
        return ""
    end
    if not variables or type(variables) ~= "table" then
        return tmpl
    end

    if not extractor_type or extractor_type == 1 then
        local result = string_gsub(tmpl,"%${([1-9]+)}",function(m)
            local t = type(variables[tonumber(m)])
            if t ~= "string" and t ~= "number" then
                return "${" .. m .. "}"
            end
            return variables[tonumber(m)]
        end)
        return result
    elseif extractor_type == 2 then
        return template.render(tmpl,variables,ngx_md5(tmpl),true)
    end
end

local _M = {}

function _M.build_url(extractor_type,url_tmpl,variables)
    return compose(extractor_type,url_tmpl,variables)
end

function _M.build_uri(extractor_type,uti_tmpl,variables)
    return compose(extractor_type,uri_tmpl,variables)
end

function _M.upstream_host(extractor_type,upstream_host_tmpl,variables)
    return compose(extractor_type,upstream_host_tmpl,variables)
end

function _M.build_upstream_url(extractor_type,upstream_url_tmpl,variables)
    return compose(extractor_type,upstream_url_tmpl,variables)
end

return _M

