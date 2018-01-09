local DB = require "db"
local type = type

return function (config)
    local user_model = {

    }
    local mysql_config = config.store_mysql
    local db = DB:new(mysql_config)

    function user_model:new(username,password,enable)
        return db:query({
            "insert into dashboard_user(username,password,enable) values(?,?,?)",
            {username,password,enable}
        })
    end
    function user_model:query(username,password)
        local res,err = db:query(
            "select * from dashboard_user where username=? and password =?",
            {username,password}
        )
        return ress,err
    end

    function user_model:query_all()
        local res,err = db:query("select id,username,is_admin,create_time,enable from dashboard_user order by id asc")
        if not res or err or type(res) ~= "table" or #res < 1 then

            return nil,err
        else 
            return res,err
        end

    end
    function user_model:query_by_id(id)
        local res,err
        if type(id) ~= "number"  then
            res = nil
            err = "query by user id is not a number type"
            return res,err
        end

        local id_query = tonumber(id)
        
        res,err = db:query("select * from dashboard_user where id =?",{id_query})
        if not res or err or type(res) ~= "table" or #res ~= 1 then
            return nil,err
        else
            return res,err
        end
        
    end
end