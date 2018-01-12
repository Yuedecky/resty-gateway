local ipairs = ipairs
local table_insert = table.insert

local pcall = pcall
local require = require

local utils = require("app.utils.utils")
local dao = require("app.store.dao")

local config_loader = require"app.utils.config_loader"
local HEADERS = {
    PROXY_LATENCY = "X-Seassoon-Proxy-Latency",
    UPSTREAM_LATENCY = "X-Seassoon-Upstream-Latency"
}

local loaded_plugins = {}
local function load_node_plugin(config,store)
    ngx.log(ngx.DEBUG,"Discovering used plugins")

    local sorted_plugins = {}
    local plugins = config.plugins

    for _, v in ipairs(plugins) do
        local loaded,plugin_handler = utils.load_module_if_exists("seassoon.plugins." .. v .. ".handler")

        if not loaded then
            ngx.log(ngx.WARN,"The following plugins is not installed or has no handler:" .. v)
        else
            ngx.log(ngx.DEBUG,"Loading plugin:" .. v)
            table_insert(sorted_plugins,{
                name = v,
                handler = plugin_handler(store)
            })
        end
    end

    table_sort(sorted_plugins,function(a,b)
        local priority_a = a.handler.PRIORITY
        local priority_b = b.handler.PRIORITY
        return priority_a > priority_b
        

    end)

    return sorted_plugins
end




local function now()
    return ngx.now() *1000
end


function App.init(options)

    options = options or {}
    local store,config
    local status,err = pcall(function()
        local config_file_path = options.config
        config = config_loader.load(conficonfig_file_pathg_path_file)
        store = require "app.store.mysql_store"
        loaded_plugin = load_node_plugin(config,store)
        ngx.update_time()
        config.seassoon_start_at = ngx.now()

    end)
    if not status or err then
        ngx.log(ngx.ERR,"Startup error:",err)
        os.exit(1)
    end
    App.data  = {
        store = store,
        config = config
    }

    return config,store
    
end

function App.init_worker()

    -- 仅在init_worker阶段使用，初始化随机因子
    math.randomseed()
    if App.data and App.data.store and App.data.config.store == "mysql" then
        local worker_id = ngx.worker.id()

        if worker_id == 0 then
            local ok,err = ngx.timer.at(0,function(premature,store,config)
                local available_plugins = config.plugins
                for _,v in ipairs(available_plugins) do
                    local load_success = dao.load_data_by_mysql(store,v)

                    if not load_success then
                        ngx.log(ngx.ERR,"failed to load data with MySQL,err:",err)
                        os.exit(1)
                    end
                end

            end,App.data.store,App.data.config)

            if not ok then
                ngx.log(ngx.ERR,"failed to create the timer:",err)
                os.exit(1)
            end

        end
    end

    for _,plugin  in ipairs(loaded_plugins) do
        plugin.handler:init_worker()
    end
end


function App.redirect()

    ngx.ctx.SEASSOON_REDIRECT_START = now()
    for _, plugin in ipairs(loaded_plugins) do
        plugin.handler:redirect()
    end

    local now_time = now()

    ngx.ctx.SEASSOON_REDIRECT_TIME = now_time - ngx.ctx.SEASSOON_REDIRECT_START

    ngx.ctx.SEASSOON_REDIRECT_END_AT = now_time

end

function App.rewrite()
    ngx.ctx.SEASSOON_REWRITE_START = now()

    for _, plugin in ipairs(loaded_plugins) do
        plugin.handler:rewrite()
    end


    local now_time = now()

    ngx.ctx.SEASSOON_REWRITE_TIME = now_time - ngx.ctx.SEASSOON_REWRITE_START
    ngx.ctx.SEASSOON_REWRITE_ENDED_AT = now_time

end


--[[
header_filter 阶段
]]
function App.header_filter()
    if ngx.ctx.ACCESSED then
        local now_time = now()
        ngx.ctx.ORANGE_WAITING_TIME = now_time - ngx.ctx.ORANGE_ACCESS_ENDED_AT -- time spent waiting for a response from upstream
        ngx.ctx.ORANGE_HEADER_FILTER_STARTED_AT = now_time
    end

    for _, plugin in ipairs(loaded_plugins) do
        plugin.handler:header_filter()
    end

    if ngx.ctx.ACCESSED then
        ngx.header[HEADERS.UPSTREAM_LATENCY] = ngx.ctx.ORANGE_WAITING_TIME
        ngx.header[HEADERS.PROXY_LATENCY] = ngx.ctx.ORANGE_PROXY_LATENCY
    end

end

function App.body_filter()

    for _, plugin in ipairs(loaded_plugins) do
        plugin.handler:body_filter()

    end

    if ngx.ctx.ACCESSED then
        ngx.ctx.SEASSOON_RECEIVE_TIME = now() - ngx.ctx.SEASSOON_HEADER_FILTER_STARTED_AT
    end


end


function App.log()
    for _, plugin in ipairs(loaded_plugins) do
        plugin.handler:log()
    end
end

return App


