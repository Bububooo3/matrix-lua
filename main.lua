print("Start:", os.clock())
local Matrix = require("matrix")
print("Init: ", os.clock())
print(Matrix.new(2,2,0))

local newMatrix = Matrix.new(3, 3, 0)
local otherMatrix = Matrix.new(3,3,1)
local thirdMatrix = Matrix.new(3,5, 2)

print("New Matrix Definition: ",newMatrix)
--newMatrix()
print("Matrix Length: ", #newMatrix)
newMatrix = 2 + newMatrix
print("Matrix/Scalar Addition: ", newMatrix)
newMatrix = otherMatrix + newMatrix
print("Matrix/Matrix Addition: ", newMatrix)
newMatrix = newMatrix * 3
print("Matrix/Scalar Multiplication: ", newMatrix)
otherMatrix:assign(2,2,732)
print("Matrix Point Value Assignment: ", otherMatrix)
print("Matrix/Matrix Multiplication: ", otherMatrix*newMatrix)
--newMatrix += thirdMatrix
print("Matrix Concat: ", thirdMatrix)
thirdMatrix = thirdMatrix/newMatrix
print("Matrix/Matrix Floor Division: ", thirdMatrix)
print("Matrix/Scalar Exponents: ", thirdMatrix^4)

for i, v in newMatrix do
  print(i,": ", v)
end

print(newMatrix:getRank(), newMatrix:getDeterminant())

print("End: ", os.clock())