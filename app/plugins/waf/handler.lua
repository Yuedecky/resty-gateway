local ipairs = ipairs
local pairs = pairs
local seassoon_db = require "app.store.seassoon_db"

local judge_util = require "app.utils.judge"
local handle_util = require "app.utils.handle"
local base_handler = require "app.plugin.base_handler"
local stat = require "app.plugins.waf.stat"

local function filter_rules(sid,plugin,ngx_var_uri)
    local rules = seassoon_db.get_json(plugin .. ".selector." .. sid .. ".rules")
    if not rules or type(rules) then

    end
end