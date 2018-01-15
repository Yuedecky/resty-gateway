local PackageInfo = require("app.conf.package_info")
local file_name = "waf"
PackageInfo:new({
},file_name)
return {
    package_info = PackageInfo.package_info,
    module_name = PackageInfo.module_name ,
    api_name =  PackageInfo.api_name,
    version  = PackageInfo.version
}