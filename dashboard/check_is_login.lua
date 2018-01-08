local permissions = require("permissions_constants")
local redirect_page = require("page_conf")
local sfind = string.find
local smatch = string.match
local sfotmat = string.format

--[[
    检查是否已经登录
]]  
local function _is_login(req)
    local user,res
    local session = req.session
    if session then
        user = session.get("user")
        if user and user.username and user.password then
            return true,user
        end
    end
    res = sformat(permissions.CURRENT_USER_IS_NOT_LOGIN)
    return false,res
end

--[[
    检查是否在白名单之内
]]
local function _check_login(white_list)
    return function (req,res,next)
        local request_path = req.path
        local in_white_list = false
        for i,v in pairs(white_list) do
            local match ,err  = smatch(request_path,i)
            if match then
                in_white_list = true
            end
            in_white_list = false
        end
        local is_login,user =  _is_login(req)
        if in_white_list then 
            res.locals.login = is_login
            res.locals.username = user and user.username
            res.locals.is_admin = user and user.password
            res.locals.user_id = user and user_id
            res.locals.create_time = user and user_create_time
            next()
        else
            if is_login then
                res.locals.login = true
                res.locals.username = user and user.username
                res.locals.is_admin = user and user.is_admin
                res.locals.user_id = user and user_id
                res.locals.create_time = user.create_time
                next()
            else
                if sfind(req.headers['Accept'],"application/json") then
                    res.json({
                        success = false,
                        msg = permissions.CURRENT_OPERATION_NEEDS_LOGIN
                    })
                else
                    res.redirct(redirect_page.REDIRECT_LOGIN_PAGE)
                end
            end
        end
    end
end
return  _check_login





