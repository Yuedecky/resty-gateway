a = "one string"
b = string.gsub(a,"one","another")
print(a)
print(b)

print(#a)

page = [[
  <html>
    <head>
      title>An HTML Page</title>
    </head>
    <body>
      <a href="http://www.lua.org">Lua</a>
    </body>
  </html>
]]

-- lua5.2支持这种写法
local data = "\x00\x01\x02\x03\x04\x05\x06\x07\z
              \x08\x09\x0A\x0B\x0C\x0D\x0E\x0F"

print(tostring(data))

print(10 .. 20)

print(type(tonumber("10")))




