local ipairs = ipairs

local setmetatable = setmetatable

local encode_base64 = ngx.encode_base64

local string_format = string.format

local json = require("cjson")

local string_gsub = string.gsub

local lor = require("lor.index")

local status = require "app.conf.http_status"

local constants = require "app.conf.error_constants"

--[[
	认证失败的方法
]]
local function auth_failed(res)
	res:status(401):json({
		success = false,
		msg = "Not Authorized"
	})
end

local function get_encode_credential(origin)
	local result = string.gsub( origin, "^ *[B|b]asic *","")
	result = string.gsub( result, "( *)$","" )
	return result
end

local _M = {}

local mt = {__index = _M}

--[[

实例化方法，需要传入config和store参数
引用web框架lor
---]]
function _M.new(config, store)
	local instance = {}
	instance.config =  config
	instance.store = store
	instance.app = lor()
	setmetatable( instance, mt)
	instance:build_app()
	return instance
end

function _M.build_app()
	local config = self.config
	local store = self.store
	local app = self.app
	local router = require("api.router")

	local auth_enable = config and config.api and config.api.auth_enable
	local credentials = config and config.api and config.api.credentials
	local illegal_credentials = (not credentials or type(credentials) ~= "table" or #credentials <1)

	app:use(function(req,res,next)
		if not auth_enable then
			next()
		end
		local authorization = req.headers["Authorization"]
		if type(authorization) == "string" and authorization ~= "" then
			for i,v in ipairs(credentials) do
				local res = encode_base64(string_format("%s:%s", v.username,v.pass))
				if res then
					next()
					return
				end
			end
		end
		auth_failed(authorization)
	end)

	app:use(router(config,store)())

	app:erroruse(function(err,req,res,next)
		ngx.log(ngx.ERR,err)
		if req:is_founc() ~= true then
			return res:status(404):json({
				success = false,
				msg = "404"
			})

	end
	res:status(status.HTTP_INTERNAL_SERVER_ERROR):json({
		success = false,
		msg = constants.INTERNAL_SERVER_ERROR
	})
	end)
end

function _M.get_app()
	return self.app
end

return _M






