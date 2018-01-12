local _M = {}

local cjson = require "cjson.safe"
cjson.encode_empty_table_as_object(false)

local mt = {
	__index = _M
}

jwt_secret = "seassoon:auth:jwt:_"

local _conf = nil

local function code_url()
	local params = ngx.encode_args({
		client_id = _conf.client_id,
		redirect_url = _conf.redirect_uri,
		scope = _conf.scope
	})
	return _conf.code_endpoint .. "?" .. params
end

