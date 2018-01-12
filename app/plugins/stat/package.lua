local version = require("app.conf.version")
return {
    module_name = "app.plugins.stat",
    api_name =  module_name .. ".api",
    version  = module_name .. ".version." .. version
}