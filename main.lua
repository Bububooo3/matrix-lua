-- RUNTIME CODE --
local Matrix = matrix
print("Init: ", os.clock())

local new = Matrix.new(3,3,1)
local other = Matrix.new(2,3,3)

other:flood({1,2,3,4,5,6})
print(new.." times "..other.." equals")
print(new*other)

print((new+1).."\n"..(1+new))
