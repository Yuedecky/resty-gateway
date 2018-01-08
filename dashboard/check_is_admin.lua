local smatch = string.match
local sfind = string.find
local permissions = require "permisson_constants"
local type = type
local function check_is_admin()
    return function(req,next,res)
        local to_check = false
        local request_path = req.path
        local match , err = smatch(request_path,"^/admin/")

        if match then 
            to_check = true
        end
        if to_check then
            local id_admin = false
            if req and req.session and req.session.get("user") then
                is_admin = req.session.get("user").is_admin
                if is_admin or is_admin == "1" then
                    id_admin = true
                end
            end
            if is_admin then
                next()
            else
                if sfind(req.headers['Accept'],"application/json") then
                    return res:json({
                        success = true,
                        msg = permissions.ADMIN_PERMISSIONS_ALLOWED
                    })
                else
                    res:render({
                        errMsg = permissions.ADMIN_PERMISSIONS_ALLOWED
                    })
                end

            end

        end
        next()
    end
end 