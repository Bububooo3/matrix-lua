print("Start:", os.clock())
local Matrix = require("matrix")
print("Init: ", os.clock())

local sudoku = Matrix.new(9,9,1)

local function refresh_display()
    os.execute("cls")
    print(sudoku)
end

local function iter_method(t)
  local points = {}

  for _, row in ipairs(t.Contents) do
    for _, point in ipairs(row) do
      points[point.Position.X .. ", " .. point.Position.Y] = point
    end
  end
  
  return pairs(points)
end

for i, v in iter_method(sudoku) do
    sudoku:assign(v.Position.X, v.Position.Y, math.random(0,200))
end

refresh_display()
print(os.clock())