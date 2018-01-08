local stringy = require "app.utils.stringy"
local _M = {}

-- 判断某个文件的路经 是否存在
function _M.file_exists(file_path)
    local res 
    local f ,err = io.open(file_path,"r")
    if f ~= nil then 
        io.close()
        return true
    else
        return false
    end

end

-- 执行os命令，捕获输出
-- @param command OS command to execute
--  @return string containing command output()
function _M.os_execute(command,preserve_output)
    local n = os.tmpname()  -- 获得临时文件名称 用于存储输出
    local f = os.tmpname() -- 获得临时文件名次 用于存储脚本
    _M.write_to_file(f,comand)
    local exit_code = os.execute("/bin/bash".. f .. ">" .. n .. "2>&1")
    local result = _M.read_file()
    os.remove(n)
    os.remove(f)
    return preserve_output and result or string.gsub( string.gsub(result,"^" .. f .. ":[%s%w]+:%s*", "" ),"[%\r%\n]",""),exit_code / 256
    
end


-- 读取文件的操作 函数
function _M.read_file(path)
    local content 
    local file,err = io.open(path)
    if file then
        content = file:read("*all")
        file:close()
    end
    return content
        
end

--写入文件方法
function _M.write_to_file(path,value)
    local file,err = io.open(path,"w")
    if err then 
        return false,nil
    end
    file:write(value)
    file:close()
    return true
end

--[[
    说明：linux系统下会有一个hash表，当你刚开机时这个hash表为空，每当你执行过一条命令时，hash表会记录下这条命令的路径，就相当于缓存一样。
    第一次执行命令shell解释器默认的会从PATH路径下寻找该命令的路径，
    当你第二次使用该命令时，shell解释器首先会查看hash表，没有该命令才会去PATH路径下寻找
]]
function _M.cmd_exists( cmd )
    local _, code = _M.os_execute("hash ".. cmd)
    return code == 0
end
-- kill pid_file
function _M.kill_process_bu_pid_file(pid_file,signal)
    if _M.file_exists(pid_file) then
        local pid = stringy.strip(_M.read_file(pid_file))
        return _M.os_execute("while kill -0 "..pid.." >/dev/null 2>&1; do kill "..(signal and "-"..tostring(signal).." " or "")..pid.."; sleep 0.1; done")
    end
end


-- 获得文件的大小
function _M.file_size(path)
    local size 
    local file =  io.open(path,"rb")
    if file  then
        size = file:seek("end")
        file:close()
    end
    return size
end


return _M