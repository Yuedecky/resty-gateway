local PackageInfo = {}
local version = require "version"
local mt = {
    __index = PackageInfo
}
local module_suffix = ".modlue"
local api_suffix = ".api"
function PackageInfo:new(conf,file_name)
    local instance = {}
    if conf and not conf.version then
        conf.version = version or "0.0.1"
    end
    if conf and not conf.module_suffix then
        conf.module_suffix = module_suffix
    end
    if conf and not conf.api_suffix then
        conf.api_suffix = api_suffix
    end
    if conf and not conf.file_name then
        conf.file_name = "app.plugin" .. file_name
    end
    instance.conf = conf
    setmetatable(instance,mt)
end
return PackageInfo