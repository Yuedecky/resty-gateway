local PackageInfo = require ("app.conf.package_info")
local file_name = "rewrite"
package_info:new({

},file_name)
return {
    package_info = PackageInfo.package_info,
    module_name = PackageInfo.module_suffix,
    version = PackageInfo.version
}