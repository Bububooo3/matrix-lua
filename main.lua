local Matrix = require('matrix.lua')
print("Init: ", os.clock())

local new = Matrix.new(9,9,1)
local t_times, limit, a = {}, 10, 0

for i=1, limit do
    new = Matrix.new(2,4,1)
    -- print(new+2)
    t_times[i] = os.clock()
end

for i=2, limit do
    a = a + (t_times[i]-t_times[i-1])
end

a = a/limit

for x, y, v in matrix.enumerate(new) do
    print(x..", "..y..": "..v)
end

print(a)
