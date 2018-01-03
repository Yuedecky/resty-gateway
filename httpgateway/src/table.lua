a= {}
a["x"] = 100
b=a
print(b['x'])
b['x'] = 20
print(a['x'])
a=nil
print(b)
b=nil
print(b)

--[[
When a program has no more references to a table, Lua¡¯s garbage collector will
eventually delete the table and reuse its memory
--]]


print("----")

tab = {}
for i = 1,100 do 
  tab[i] = i *2 
end
print(tab[10])
tab['x'] = 19
print(tab['x'])
print(tab['y'])



print("---")

a = {}
for i = 1, 3 do
  a[i] = io.read()
end

print(a[1])
