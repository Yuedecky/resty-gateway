line = io.read()
n = tonumber(line)
if n == nil  then
   error(line  .. "is not a number")
else
   print(line *2)
end