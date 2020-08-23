require("socket")

while true do
   local t = socket.gettime()*10000
   print(t)
end

