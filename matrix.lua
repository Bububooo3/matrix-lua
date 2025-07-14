-- DataType
-- Created by Dynamo (@Roller_Bott)
-- Created 4/18/25
-- Last Updated 7/12/25
-- these notes keep me sane

-- Matrix Class Library
local matrix = {}
local className = "Matrix"
local emergency_metatable = function(matrix)
  print("Sorry, the metamethods function has not been initialized yet!")
end

-- Matrix DataType Info --

local properties = {
  "ClassName",
  "Size",
  "Contents",
  "assign",
  "flood",
  "fill",
  "replace",
  "transpose",
  "getDeterminant",
  "getRank",
  "getArea",
  "getDimensions",
  "getInverse",
  "getTrace",
  "getIdentity",
  "Zero",
  "One",
  "isSymmetric",
  "isSingular",
  "isInvertible",
  "find",
  "insertRow",    ----> Experimental
  "insertColumn", ----> Doesn't work
}


local allowedTypes = {
  "number",
  "table"
}

local function find(haystack, needle, init)
  if not init then init = 1 end
  for i = init, #haystack do
    if haystack[i] == needle then return i end
  end
  return nil
end

local function roundToDigits(value, digits, text)
  local startdigits = #tostring(math.floor(math.abs(value)))
  local decimals = math.max(0, digits - startdigits - 1) -- The 1 is to account for the '.' so the matrix looks pretty
  local mult = 10 ^ decimals
  local rounded = math.floor(value * mult + 0.5) / mult

  if text then return string.format("%." .. decimals .. "f", rounded) end
  return rounded
end

local function cloneMatrix(oldmatrix)
  local copy = {}
  copy.Size = { A = oldmatrix.Size.A, B = oldmatrix.Size.B }
  copy.ClassName = className
  copy.Contents = {}

  for i, row in ipairs(oldmatrix.Contents) do
    copy.Contents[i] = {}
    for j, point in ipairs(row) do
      copy.Contents[i][j] = point
    end
  end

  return copy -- raw and without metamethods
end

local function createIdentityMatrix(n) --The one with all the ones and zeros
  local identity = {}                  -- n x n
  identity.Size = {}
  identity.Size.A = n
  identity.Size.B = n
  identity.ClassName = className
  identity.Contents = {}

  for i = 1, n, 1 do
    identity.Contents[i] = {}
    for j = 1, n, 1 do
      identity.Contents[i][j] = { Value = (i == j) and 1 or 0 } -- Just learned about this. It's pretty neat!
    end
  end



  return setmetatable(identity, { __index = matrix })
end

local function invertMatrix(oldmatrix) -- Gauss-Jordan Matrix Inversion (this stuff is useful, but I am going to have an aneurysm trying to code it)
  local mclone = cloneMatrix(oldmatrix)
  local msize = { A = oldmatrix.Size.A, B = oldmatrix.Size.B }
  local midentity = createIdentityMatrix(msize.A) -- A or B doesn't matter bc it's squared

  
  for i = 1, msize.A do
    -- Find pivot (diagonal of '1's) (One 1 per column so we can search recursively and stuff)
    local pivot_point = mclone.Contents[i][i]

    if pivot_point.Value == 0 then
      -- Cycle down the column
      for j = i + 1, msize.A do -- i+1 bc [i][i] is 0
        if mclone.Contents[j][i].Value == 0 then goto continue end
        -- Swap rows to have a nonzero pivot point (like an algebraic equation whatever we do to one side, we must also do to the other (identity matrix))
        mclone.Contents[i], mclone.Contents[j] = mclone.Contents[j], mclone.Contents[i]
        midentity.Contents[i], midentity.Contents[j] = midentity.Contents[j], midentity.Contents[i]
        pivot_point = mclone.Contents[i][i]
        break
        ::continue::
      end
    end

    if pivot_point==0 then error("Matrix is singular, and thus indivisible") end
    
    -- Step 2 aaaaaa
    -- Make pivot point equal to 1 by dividing every value in the row by the pivot point value
    for j = 1, msize.A do
      mclone.Contents[i][j].Value = mclone.Contents[i][j].Value / pivot_point.Value
      midentity.Contents[i][j].Value = midentity.Contents[i][j].Value / pivot_point.Value
    end

    -- Step 3 ;-; (We're almost there!)
    -- Praying this works off rip (it DID NOT work off rip ;-;)
    -- Do the math on rows that aren't on the pivot
    for k = 1, msize.A do
      if k == i then goto continue end
      local factor = mclone.Contents[k][i].Value
      for j = 1, msize.A do
        mclone.Contents[k][j].Value = mclone.Contents[k][j].Value - (factor * mclone.Contents[i][j].Value)
        midentity.Contents[k][j].Value = midentity.Contents[k][j].Value - (factor * midentity.Contents[i][j].Value)
      end
      ::continue::
    end
  end

  for y, row in ipairs(midentity.Contents) do
    for x, point in ipairs(row) do
      point.Position = { X = x, Y = y }
    end
  end

  --print(midentity) -- OOPS! Forgot the positions somehow? aaaaa
  return midentity
end

local function transposeMatrix(oldmatrix) -- Basically rotate it
  local newMatrix = {}
  newMatrix.Size = { A = oldmatrix.Size.B, B = oldmatrix.Size.A }
  newMatrix.ClassName = className
  newMatrix.Contents = {}

  for i = 1, oldmatrix.Size.A, 1 do
    newMatrix.Contents[i] = {}
    for j = 1, oldmatrix.Size.B, 1 do
      newMatrix.Contents[i][j] = oldmatrix.Contents[j][i]
    end
  end

  return newMatrix
end

--[[ Orthonormalized Attempt (I'll learn more about it later)

local function dotProduct(a, b)
  local sum = 0
  print(a, b)
  for i=1, #a do
    sum = a[i].Value * b[i].Value + sum
  end
  return sum
end

local function scaleVector(vectr, scalar)
  local result = {}
  for i = 1, #vectr do
    local newPoint = {}
    newPoint.Value, newPoint.Position = {}, {}
    newPoint.Value = vectr[i].Value * scalar
    newPoint.Position.X = vectr[i].Position.X
    newPoint.Position.Y = vectr[i].Position.Y

    table.insert(result, newPoint.Position.X, newPoint)
  end

  return result
end

local function normalizeVector(vectr)
  local vector_length = math.sqrt(dotProduct(vectr, vectr))

  if vector_length == 0 then error("Attempt to normalize zero vector") end
  print("scale")
  return scaleVector(vectr, 1/vector_length)
end
]]

-- METAMETHODS
local function new_index_method(_, key, _)
  if find(properties, key) then error("Unable to configure property " .. key .. ". Property is read only") end
  error("Unable to configure property " .. tostring(key) .. ". Property does not exist")
end

local function length_method(t)
  local points = 0
  for _, row in ipairs(t.Contents) do
    points = #row + points
  end
  return points
end

local matrix_metatable_str = "Matrix"

local function call_method(t)
  for _, row in ipairs(t.Contents) do
    for _, point in ipairs(row) do
      print("(" .. tostring(point.Position.X) .. ", " .. tostring(point.Position.Y) .. ") " .. tostring(point.Value))
    end
  end
end

local function concat_method(t, _)
  local writtenTable = {}
  local mostdigits = 0

  for i = 1, t.Size.B, 1 do
    for _, point in pairs(t.Contents[i]) do
      if string.len(tostring(point.Value)) > mostdigits then mostdigits = string.len(tostring(point.Value)); end
    end
  end

  for i = 1, t.Size.B, 1 do
    local currentRow = t.Contents[i]
    local values = {}

    for _, point in ipairs(currentRow) do
      table.insert(values, point.Position.X, roundToDigits(point.Value, mostdigits, true))
    end

    writtenTable[i] = table.concat(values, ", ")
  end

  local resultant = ""

  for i, row in ipairs(writtenTable) do
    -- if i == 1 then
    --   resultant = resultant .. "\n⌈ " .. row .. " ⌉\n"
    -- elseif i == #writtenTable then
    --   resultant = resultant .. "\n⌊ " .. row .. " ⌋\n"
    -- else
    --   resultant = resultant .. "\n| " .. row .. " |\n"
    -- end

    resultant = resultant .. "\n[ " .. row .. " ]\n"
  end

  return resultant
end

local function tostring_method(t)
  local writtenTable = {}
  local mostdigits = 0

  for i = 1, t.Size.B, 1 do
    for _, point in ipairs(t.Contents[i]) do
      if string.len(tostring(point.Value)) > mostdigits then mostdigits = string.len(tostring(point.Value)); end
    end
  end

  for i = 1, t.Size.B, 1 do
    local currentRow = t.Contents[i]
    local values = {}

    --print(mostdigits)
    for _, point in ipairs(currentRow) do
      table.insert(values, point.Position.X, roundToDigits(point.Value, mostdigits, true))
    end

    writtenTable[i] = table.concat(values, ", ")
  end

  local resultant = ""

  for i, row in ipairs(writtenTable) do
    -- if i == 1 then
    --   resultant = resultant .. "\n⌈ " .. row .. " ⌉\n"
    -- elseif i == #writtenTable then
    --   resultant = resultant .. "\n⌊ " .. row .. " ⌋\n"
    -- else
    --   resultant = resultant .. "\n| " .. row .. " |\n"
    -- end

    resultant = resultant .. "\n[ " .. row .. " ]\n"
  end

  return resultant
end

local function unary_minus_method(t)
  for i = 1, t.Size.B, 1 do
    for _, point in ipairs(t.Contents[i]) do
      point.Value = -point.Value
    end
  end

  return t
end

local function add_method(t, value)
  if not find(allowedTypes, type(value)) and not(getmetatable(value)=="Matrix") then
    error("Attempt to perform arithmetic between Matrix and " ..
      type(value))
  end

  if type(t) == "number" and getmetatable(value) == "Matrix" then
    for i = 1, value.Size.B, 1 do
      for _, point in ipairs(value.Contents[i]) do
        point.Value = t + point.Value
      end
    end

    return value
  elseif getmetatable(value) == "Matrix" then
    if type(value) == "number" then
      for i = 1, t.Size.B, 1 do
        for _, point in ipairs(t.Contents[i]) do
          point.Value = value + point.Value
        end
      end

      return t
    elseif getmetatable(value) == "Matrix" then
      if not (value.Contents and value.Size) then error("Attempt to perform arithmetic on malformed Matrix") end
      if not (value.Size.A == t.Size.A and value.Size.B == t.Size.B) then
        error(
          "Terminated attempt to perform arithmetic between Matrices of different proportions")
      end
      for i = 1, t.Size.B, 1 do
        for j, point in ipairs(t.Contents[i]) do
          point.Value = value.Contents[i][j].Value + point.Value
        end
      end
      return t
    end
  end
end

local function sub_method(t, value)
  if not find(allowedTypes, type(value)) and not(getmetatable(value)=="Matrix") then
    error("Attempt to perform arithmetic between Matrix and " ..
      type(value))
  end

  if getmetatable(t) == "Matrix" then
    if type(value) == "number" then
      for i = 1, t.Size.B, 1 do
        for _, point in ipairs(t.Contents[i]) do
          point.Value = point.Value - value
        end
      end

      return t
    elseif getmetatable(value) == "Matrix" then
      if not (value.Contents and value.Size) then error("Attempt to perform arithmetic on malformed Matrix") end
      if not (value.Size.A == t.Size.A and value.Size.B == t.Size.B) then
        error(
          "Terminated attempt to perform arithmetic between Matrices of different proportions")
      end
      for i = 1, t.Size.B, 1 do
        for j, point in ipairs(t.Contents[i]) do
          point.Value = point.Value - value.Contents[i][j].Value
        end
      end

      return t
    end
  elseif type(t) == "number" then
    error("Attempt to subtract a Matrix from a Scalar")
  end
end

local function mul_method(t, value)
  if not find(allowedTypes, type(value)) and not(getmetatable(value)=="Matrix") then
    error("Attempt to perform arithmetic between Matrix and " ..
      type(value))
  end
  if getmetatable(t) == "Matrix" then
    if type(value) == "number" then
      for i = 1, t.Size.B, 1 do
        for _, point in ipairs(t.Contents[i]) do
          point.Value = point.Value * value
        end
      end

      return t
    elseif getmetatable(value) == "Matrix" then
      if not (value.Contents and value.Size) then error("Attempt to perform arithmetic on malformed Matrix") end
      if not (t.Size.A == value.Size.B) then
        error(
          "Terminated attempt to perform arithmetic between Matrices of different proportions (#Rows ~= #Columns)")
      end

      local resultMatrix = { Size = { A = t.Size.A, B = value.Size.B }, Contents = {}, ClassName = className }

      for i = 1, t.Size.A do
        local currentRow = t.Contents[i]

        for j = 1, value.Size.B, 1 do
          local sum = 0

          for k = 1, t.Size.A, 1 do
            sum = currentRow[k].Value * value.Contents[k][j].Value + sum
          end

          -- need a result matrix
          if not (resultMatrix.Contents[i]) then resultMatrix.Contents[i] = {} end
          if not (resultMatrix.Contents[i][j]) then
            resultMatrix.Contents[i][j] = { Value = sum, Position = { X = j, Y = i } }
          end
        end
      end

      return emergency_metatable(resultMatrix)
    end
  elseif type(t) == "number" then
    for i = 1, value.Size.B, 1 do
      for _, point in ipairs(value.Contents[i]) do
        point.Value = point.Value * t
      end
    end
  else
    error("Attempt to perform arithmetic between Matrix and " .. type(value))
  end
end

local function div_method(t, value)
  if not (getmetatable(t) == "Matrix") then error("Attempt to divide a " .. type(t) .. " by a Matrix") end
  if not find(allowedTypes, type(value)) and not(getmetatable(value)=="Matrix") then
    error("Attempt to perform arithmetic between Matrix and " ..
      type(value))
  end
  if type(value) == "number" then
    for i = 1, t.Size.B, 1 do
      for _, point in ipairs(t.Contents[i]) do
        point.Value = point.Value / value
      end
    end

    return t
  elseif getmetatable(value) == "Matrix" then
    if not (value.Contents and value.Size) then error("Attempt to perform arithmetic on malformed Matrix") end
    -- multiply the left matrix by the inverse of the right matrix [table * inverse(value)]
    if not (t.Size.A == value.Size.A) then
      error(
        "Terminated attempt to perform arithmetic between Matrices of different proportions (#Rows ~= #Columns)")
    end                                  -- bc it will be the inverse size that has to be equal
    if value.Size.A == value.Size.B then -- Do Gauss-Jordan
      local invertedMatrix = emergency_metatable(invertMatrix(value))
      local quotient = t * invertedMatrix
      return quotient
    else -- Maybe try using Moore-Penrose sometime ;-;
      -- I don't completely understand WHY it works (like all the math behind this equation), but I do know that it works so I'll use it
      -- Have to do pseudoinversion here bc metamethods are needed
      local matrix_t = emergency_metatable(transposeMatrix(value)) -- To get full row/column rank

      if value.Size.B >= value.Size.A then                         -- If #rows >= #columns (tall) [Order matters]
        -- inverse(matrix_t*matrix) * matrix_t = matrix_pseudoinverse
        -- matrix_t*matrix aka Mt * M aka MtM
        local MtM = matrix_t * matrix
        local invMtM = emergency_metatable(invertMatrix(MtM))

        return invMtM * matrix_t
      else -- If #columns > #rows (wide)
        -- matrix_t * inverse(matrix_t*matrix) = matrix_pseudoinverse
        -- matrix*matrix_t aka M * Mt aka Mt
        local MMt = matrix * matrix_t
        local invMMt = emergency_metatable(invertMatrix(MMt))

        return matrix_t * invMMt
      end
    end
  end
end

local function idiv_method(t, value)
  if not (getmetatable(t) == "Matrix") then error("Attempt to divide a " .. type(t) .. " by a Matrix") end
  if not find(allowedTypes, type(value)) and not(getmetatable(value)=="Matrix") then
    error("Attempt to perform arithmetic between Matrix and " ..
      type(value))
  end
  if type(value) == "number" then
    for i = 1, t.Size.B, 1 do
      for _, point in ipairs(t.Contents[i]) do
        point.Value = math.floor(point.Value / value)
      end
    end

    return t
  elseif getmetatable(value) == "Matrix" then
    if not (value.Contents and value.Size) then error("Attempt to perform arithmetic on malformed Matrix") end
    -- multiply the left matrix by the inverse of the right matrix [table * inverse(value)]
    if not (t.Size.A == value.Size.A) then
      error(
        "Terminated attempt to perform arithmetic between Matrices of different proportions (#Rows ~= #Columns)")
    end                                  -- bc it will be the inverse size that has to be equal
    if value.Size.A == value.Size.B then -- Do Gauss-Jordan
      local invertedMatrix = emergency_metatable(invertMatrix(value))
      local quotient = t * invertedMatrix

      for _, row in ipairs(quotient.Contents) do
        for _, point in ipairs(row) do
          point.Value = roundToDigits(point.Value, string.len(tostring(point.Value)))
          ---@diagnostic disable-next-line: param-type-mismatch
          point.Value = math.abs(point.Value) -- prevent -0 ^^^ so annoying
        end
      end

      return quotient
    else -- Maybe try using Moore-Penrose sometime ;-;
      -- I don't completely understand WHY it works (like all the math behind this equation), but I do know that it works so I'll use it
      -- Have to do pseudoinversion here bc metamethods are needed

      local matrix_t = emergency_metatable(transposeMatrix(value)) -- To get full row/column rank

      if value.Size.B >= value.Size.A then                         -- If #rows >= #columns (tall) [Order matters]
        -- inverse(matrix_t*matrix) * matrix_t = matrix_pseudoinverse
        -- matrix_t*matrix aka Mt * M aka MtM
        local MtM = matrix_t * matrix
        local invMtM = emergency_metatable(invertMatrix(MtM))

        local raw_matrix = invMtM * matrix_t

        for _, row in ipairs(raw_matrix.Contents) do
          for _, point in ipairs(row) do
            point.Value = roundToDigits(point.Value, string.len(tostring(point.Value)))
          end
        end

        return raw_matrix
      else -- If #columns > #rows (wide)
        -- matrix_t * inverse(matrix_t*matrix) = matrix_pseudoinverse
        -- matrix*matrix_t aka M * Mt aka Mt
        local MMt = matrix * matrix_t
        local invMMt = emergency_metatable(invertMatrix(MMt))

        local raw_matrix = matrix_t * invMMt

        for _, row in ipairs(raw_matrix.Contents) do
          for _, point in ipairs(row) do
            point.Value = roundToDigits(point.Value, string.len(tostring(point.Value)))
          end
        end

        return raw_matrix
      end
    end
  end
end

local function mod_method(t, value)
  if not (getmetatable(t) == "Matrix") then error("Attempt to divide a " .. type(t) .. " by a Matrix") end
  if type(value) == "number" then
    for _, row in ipairs(t.Contents) do
      for _, point in ipairs(row) do
        point.Value = point.Value % value
      end
    end

    return t
  elseif getmetatable(value) == "Matrix" then
    if not (value.Size and value.Contents) then error("Attempt to perform arithmetic on malformed Matrix") end
    if not ((value.Size.A == t.Size.A) and (value.Size.B == t.Size.B)) then
      error("Attempt to perform modulus operation on Matrix of size " ..
        t.Size.A .. "x" .. t.Size.B .. " and Matrix of size " .. value.Size.A .. "x" .. value.Size.B)
    end
    for y, row in ipairs(t.Contents) do
      for x, point in ipairs(row) do
        point.Value = point.Value % value.Contents[y][x].Value
      end
    end

    return t
  else
    error("Attempt to perform arithmetic between Matrix and " .. type(value))
  end
end

local function pow_method(t, value)
  if not (getmetatable(t) == "Matrix") then error("Attempt to use Matrix as an exponent") end
  if not (type(value) == "number") then error("Attempt to raise Matrix to non-scalar exponent") end
  local base = t

  if not (t.Size.A == t.Size.B) then error("Attempt to raise Matrix of non-square proportions to an exponent") end
  for _ = 1, value, 1 do
    t = t * base
  end

  return t
end

local function eq_method(t, value)
  if getmetatable(t) == "Matrix" then
    if type(value) == "number" then
      for _, row in ipairs(t.Contents) do
        for _, point in ipairs(row) do
          if point.Value ~= value then
            return false
          end
        end
      end

      return true
    elseif getmetatable(value) == "Matrix" then
      if not (value.Size and value.Contents) then error("Attempt to index a malformed Matrix") end
      if not (value.Size.A == t.Size.A and value.Size.B == t.Size.B) then
        error(
          "Attempt to compare nonsimilar Matrices")
      end
      for y, row in ipairs(t.Contents) do
        for x, point in ipairs(row) do
          if point.Value ~= value.Contents[y][x].Value then
            return false
          end
        end
      end

      return true
    else
      error("Attempt to compare Matrix and " .. type(value))
    end
  elseif type(t) == "number" then
    for _, row in ipairs(value.Contents) do
      for _, point in ipairs(row) do
        if point.Value ~= t then
          return false
        end
      end
    end
    return true
  end
  error("Comparison failed between " .. t .. " (" .. type(t) .. ") and " .. value .. " (" .. type(value) .. ")")
end

local function lt_method(t, value)
  if getmetatable(t) == "Matrix" then
    if type(value) == "number" then
      for _, row in ipairs(t.Contents) do
        for _, point in ipairs(row) do
          if not (point.Value < value) then
            return false
          end
        end
      end

      return true
    elseif getmetatable(value) == "Matrix" then
      if not (value.Size and value.Contents) then error("Attempt to index a malformed Matrix") end
      if not (value.Size.A == t.Size.A and value.Size.B == t.Size.B) then
        error(
          "Attempt to compare nonsimilar Matrices")
      end
      for y, row in ipairs(t.Contents) do
        for x, point in ipairs(row) do
          if not (point.Value < value.Contents[y][x].Value) then
            return false
          end
        end
      end

      return true
    else
      error("Attempt to compare Matrix and " .. type(value))
    end
  else
    if not (type(t) == "number") then error("Attempt to compare Matrix and " .. type(value)) end

    for _, row in ipairs(value.Contents) do
      for _, point in ipairs(row) do
        if not (point.Value < t) then
          return false
        end
      end
    end

    return true
  end
end

local function le_method(t, value)
  if getmetatable(t) == "Matrix" then
    if type(value) == "number" then
      for _, row in ipairs(t.Contents) do
        for _, point in ipairs(row) do
          if not (point.Value <= value) then
            return false
          end
        end
      end

      return true
    elseif getmetatable(value) == "Matrix" then
      if not (value.Size and value.Contents) then error("Attempt to index a malformed Matrix") end
      if not (value.Size.A == t.Size.A and value.Size.B == t.Size.B) then
        error(
          "Attempt to compare nonsimilar Matrices")
      end
      for y, row in ipairs(t.Contents) do
        for x, point in ipairs(row) do
          if not (point.Value <= value.Contents[y][x].Value) then
            return false
          end
        end
      end

      return true
    else
      error("Attempt to index Matrix and " .. type(value))
    end
  else
    if not (type(t) == "number") then error("Attempt to compare Matrix and " .. type(value)) end

    for _, row in ipairs(value.Contents) do
      for _, point in ipairs(row) do
        if not (point.Value <= t) then
          return false
        end
      end
    end

    return true
  end
end

local function iter_method(t)
  local points = {}

  for _, row in ipairs(t.Contents) do
    for _, point in ipairs(row) do
      points[point.Position.X .. ", " .. point.Position.Y] = point.Value
    end
  end

  return ipairs(points)
end

-- Metatable Function
local function metamethods(givenmatrix)
  setmetatable(givenmatrix, {
    __index = matrix,

    __newindex = new_index_method,

    __len = length_method,

    __metatable = matrix_metatable_str,

    __call = call_method,

    __concat = concat_method,

    __tostring = tostring_method,

    __unm = unary_minus_method,

    __add = add_method,

    __sub = sub_method,

    __mul = mul_method,

    __div = div_method,

    __idiv = idiv_method,

    __mod = mod_method,

    __pow = pow_method,

    __eq = eq_method,

    __lt = lt_method,

    __le = le_method,

    __iter = iter_method,

  })

  return givenmatrix
end

emergency_metatable = metamethods

local function findDeterminant(t) -- for recursive searching
  if t.Size.A == 1 then
    return t.Contents[1][1].Value
  elseif t.Size.A == 2 then
    return t.Contents[1][1].Value * t.Contents[2][2].Value - t.Contents[1][2].Value * t.Contents[2][1].Value
  else
    -- Using Cramer's Rule
    local det = 0

    for column = 1, t.Size.A, 1 do
      local minor = {}
      minor.Contents = {}
      minor.Size = {}
      minor.ClassName = className

      for i = 2, t.Size.A do
        minor.Contents[i - 1] = {}
        for j = 1, t.Size.A do
          if j == t.Size.A then goto continue end
          table.insert(minor.Contents[i - 1], t.Contents[i][j])
          ::continue::
        end
      end

      minor.Size.A, minor.Size.B = #minor.Contents[1], #minor.Contents
      minor = metamethods(minor)

      local sign = ((column % 2 == 1) and 1) or -1
      det = sign * t.Contents[1][column].Value * findDeterminant(minor) + det
    end
    return det
  end
end

local function newRow(currentrow, columns, defaultvalue)
  local row = {}

  for i = 1, columns, 1 do
    local temporary_point = {
      ["Value"] = defaultvalue,
      ["Position"] = {
        ["X"] = i,
        ["Y"] = currentrow
      }
    }

    setmetatable(temporary_point, {
      __index = function(t, key)
        --print(key)

        if string.lower(key) == "value" then
          return rawget(t, "Value")
        elseif string.lower(key) == "position" then
          return rawget(t, "Position")
        elseif string.lower(key) == "x" or string.lower(key) == "column" then
          return rawget(t, "Position").X
        elseif string.lower(key) == "y" or string.lower(key) == "row" then
          return rawget(t, "Position").Y
        else
          warn(key .. " is not a property of the 'point' class. Returning " .. t.Value .. " in its place...")
          return t.Value
        end
      end,

      __newindex = function(_, key, _)
        error(key .. " is not a valid member of the 'point' class")
      end,

    })

    row[i] = temporary_point
  end

  return row
end


matrix.__index = matrix


-- CONSTRUCTOR

-- Create a new empty matrix. Without default value, the default value is set equal to 0.
function matrix.new(columns, rows, defaultvalue)
  local self = setmetatable({}, matrix)

  assert(columns > 0, "Attempt to define #columns as a non-natural number")
  assert(rows > 0, "Attempt to define #rows as a non-natural number")

  if not (defaultvalue) then defaultvalue = 0; end

  self.ClassName = className
  self.Size = { A = columns, B = rows }

  self.Contents = {}

  for i = 1, rows, 1 do
    self.Contents[i] = newRow(i, columns, defaultvalue)
  end

  return metamethods(self)
end

-- CLASS METHODS

function matrix:fill(value)
  for _, row in ipairs(self.Contents) do
    for _, point in ipairs(row) do
      point.Value = value
    end
  end

  return self
end

function matrix:flood(value)
  if self.Size.A * self.Size.B == #value then
    local index = 1
    for _, row in ipairs(self.Contents) do
      for _, point in ipairs(row) do
        point.Value = value[index]
        index = 1 + index
      end
    end

    return self
  else
    error("Number of values in table does not match number of values in Matrix")
  end
end

function matrix:getArea()
  return self.Size.A * self.Size.B
end

function matrix:getInverse()
  if self.Size.A == self.Size.B then
    local invertedMatrix = metamethods(invertMatrix(self))
    return invertedMatrix
  else
    local matrix_t = metamethods(transposeMatrix(self))

    if self.Size.B >= self.Size.A then
      local MtM = matrix_t * matrix
      local invMtM = metamethods(invertMatrix(MtM))

      return invMtM
    else
      local MMt = matrix * matrix_t
      local invMMt = metamethods(invertMatrix(MMt))

      return invMMt
    end
  end
end

function matrix:getDimensions()
  return self.Size.A, self.Size.B
end

function matrix:replace(replace, value)
  for _, row in ipairs(self.Contents) do
    for _, point in ipairs(row) do
      if point.Value == replace then
        point.Value = value
      end
    end
  end

  return self
end

function matrix:getDeterminant() -- Recursive searching may cause lag with large matrices
  return findDeterminant(self)
end

function matrix:transpose()
  local newMatrix = metamethods(transposeMatrix(self))
  return newMatrix
end

function matrix:getRank()
  local rank = 0

  local init = 1

  for x = 1, self.Size.A do
    local pivot_row -- Row w/ first non-zero entry (pivot element)
    for y = init, self.Size.B do
      if math.abs(self.Contents[x][y].Value) > 1e-10 then
        pivot_row = x
        break
      end
    end

    if pivot_row then
      self.Contents[init], self.Contents[pivot_row] = self.Contents[pivot_row], self.Contents[init]

      -- just learned this is called normalization
      local pivot = self.Contents[init][x].Value

      for column = x, self.Size.A do
        self.Contents[init][column].Value = self.Contents[init][column].Value / pivot
      end

      for row = init + 1, self.Size.B do -- Start at next row
        local factor = self.Contents[row][x].Value
        for column = x, self.Size.A do
          self.Contents[row][column].Value = self.Contents[row][column].Value - factor *
              self.Contents[init][column].Value
        end
      end

      rank = rank + 1
      init = init + 1
    end
  end

  return rank
end

function matrix:getTrace()
  if self.Size.A == self.Size.B then
    local total = 0

    for y, row in ipairs(self.Contents) do
      total = row[y].Value + total
    end

    return total
  else
    error("Attempt to retrieve trace of a non-square Matrix")
  end
end

-- Insert a new point of a defined value into the matrix at (column, row) aka (x,y)
function matrix:assign(column, row, value)
  assert(value ~= nil, "Value is set to nil")
  assert(column ~= nil, "Column is set to nil")
  assert(row ~= nil, "Row is set to nil")
  --print(self.Size, row)
  --assert(self.Size.A >= column, "Column "..column.." does not exist in "..self) <- SOMEHOW MAKES SIZE == nil
  --assert(self.Size.B >= row, "Row "..row.." does not exist in "..self) <- SOMEHOW MAKES SIZE == nil

  assert(column > 0, "Attempt to insert value in column at a non-natural number")
  assert(row > 0, "Attempt to insert value in row at a non-natural number")

  self.Contents[row][column].Value = value

  return self
end

function matrix:Zero()
  local newMatrix = matrix.new(self.Size.A, self.Size.B, 0)
  return newMatrix
end

function matrix:One()
  local newMatrix = matrix.new(self.Size.A, self.Size.B, 1)
  return newMatrix
end

function matrix:getIdentity()
  if self.Size.A == self.Size.B then
    local identityMatrix = matrix.new(self.Size.A, self.Size.B, 0)

    for y, row in ipairs(self.Contents) do
      for x, _ in ipairs(row) do
        if x == y then
          identityMatrix.Contents[y][x].Value = 1
        end
      end
    end

    return identityMatrix
  else
    error("Attempt to create identity of a non-square Matrix")
  end
end

function matrix:getDiagonal()
  if self.Size.A == self.Size.B then
    local diagonalMatrix = matrix.new(self.Size.A, self.Size.B, 0)

    for y, row in ipairs(self.Contents) do
      for x, point in ipairs(row) do
        if x == y then
          diagonalMatrix.Contents[y][x].Value = point.Value
        end
      end
    end

    return diagonalMatrix
  else
    error("Attempt to create diagonal matrix using a non-square Matrix")
  end
end

function matrix:isSymmetric()
  if self.Size.A ~= self.Size.B then return false end

  for y, row in ipairs(self.Contents) do
    for x, point in ipairs(row) do
      if self.Contents[x][y].Value ~= point.Value then
        return false
      end
    end
  end

  return true
end

function matrix:isAntiSymmetric()
  if self.Size.A ~= self.Size.B then return false end

  for y, row in ipairs(self.Contents) do
    for x, point in ipairs(row) do
      if y == x then
        if point.Value ~= 0 then
          return false
        end
      else
        if self.Contents[x][y].Value ~= -point.Value then
          return false
        end
      end
    end
  end

  return true
end

--function matrixgetRowsOrthonormalized()
--	local ortho = {}

--	for y = 1, #self.Contents, 1 do
--		--print("e")
--		local vi = {table.unpack(self.Contents[y])}
--		--print(vi)
--		for j = 1, #ortho do
--			--print(ortho)
--			--print("scale & dotproduct")
--			local proj = scaleVector(ortho[j], dotProduct(vi, ortho[j]))
--			--print("subtract")
--			vi = subtractVectors(vi, proj)
--		end
--		--print("normalize")
--		table.insert(ortho, normalizeVector(vi))
--		--print("Ortho ",ortho)
--	end

--	local orthoMatrix = matrix.new(self.Size.A, self.Size.B)
--	orthoMatrixflood(ortho)

--	return orthoMatrix
--end

function matrix:find(needle, initx, inity)
  for y, row in ipairs(self.Contents) do
    if y > inity then
      for _, point in ipairs(row) do
        if point.Value == needle then
          return point.Position
        end
      end
    elseif y == inity then
      for x, point in ipairs(row) do
        if x >= initx then
          if point.Value == needle then
            return point.Position
          end
        end
      end
    end
  end
end

function matrix:insertRow(points, position)
  if not (#points == self.Size.B) then
    error("Attempt to insert row with invalid number of points")
  end
  if not (position) or type(position) ~= "number" then position = #self.Contents end
  if (position <= 0) or (position > self.Size.B + 1) then
    error("Attempt to insert row at invalid position")
  end

  if (self.Contents[position]) then
    -- Shift every row down one
    for i = #self.Contents, position, -1 do
      self.Contents[i + 1] = self.Contents[i]
    end
  end

  self.Contents[position] = newRow(#self.Contents, self.Size.B, 0)

  for i, point in ipairs(points) do
    self.Contents[position][i] = point or point.Value
  end

  self.Size.B = 1 + self.Size.B

  return self
end

function matrix:removeRow(position)
  if not (position) or type(position) ~= "number" then position = #self.Contents end
  if (position <= 0) or (position > self.Size.B) then
    error("Attempt to remove row at invalid position")
  end
  if self.Size.B == 1 then
    error("Attempt to remove row from Matrix with one row")
  end

  -- shift every row below this position up
  for i = position, #self.Contents do
    if not (i == 1) then
      self.Contents[i - 1] = self.Contents[i]

      if i == #self.Contents then
        table.remove(self.Contents, i)
      end
    else
      table.remove(self.Contents, i)
    end
  end

  self.Size.B = self.Size.B - 1

  return self
end

function matrix:insertColumn(points, position)
  if not (#points == self.Size.A) then
    error("Attempt to insert column with invalid number of points")
  end
  if not (position) or type(position) ~= "number" then position = self.Size.A + 1 end
  if (position <= 0) or (position > self.Size.A + 1) then
    error("Attempt to insert column at invalid position")
  end

  if (self.Size.A >= position) then
    -- Shift every column right one
    for i = 1, self.Size.B do
      self.Contents[i][position].Position.X = 1 + self.Contents[i][position].Position.X
    end
  end

  -- Set every value with x = position to corresponding point in table
  for y, row in ipairs(self.Contents) do
    local point = points[y]
    if point then
      row[position].Value = point or point.Value
    end
  end
  self.Size.A = 1 + self.Size.A

  return self
end

function matrix:removeColumn(position)
  if not (position) or type(position) ~= "number" then position = #self.Contents end
  if (position <= 0) or (position > self.Size.A) then
    error("Attempt to remove row at invalid position")
  end
  if self.Size.A == 1 then
    error("Attempt to remove column from Matrix with one column")
  end

  -- shift every column to the right this position left one
  for x = position, self.Size.A, 1 do
    for _, row in ipairs(self.Contents) do
      row[x].Position.X = row[x].Position.X - 1

      if row[x].Position.X == 0 then
        table.remove(row, x)
      end
    end
  end


  for i = position, #self.Contents do
    if not (i == 1) then
      self.Contents[i - 1] = self.Contents[i]

      if i == #self.Contents then
        self.Contents[i] = { Maximum = 0, Minimum = 0 }
      end
    end
  end

  self.Size.A = self.Size.A - 1

  return self
end

function matrix:isSingular()
  if self:getDeterminant() == 0 then
    return true
  else
    return false
  end
end

function matrix:isInvertible()
  if self:getDeterminant() == 0 then
    return false
  else
    return true
  end
end

function matrix.zero(columns, rows)
  if not (columns) or not (rows) then columns, rows = 2, 2 end

  local newMatrix = matrix.new(columns, rows, 0)
  return newMatrix
end

function matrix.one(columns, rows)
  if not (columns) or not (rows) then columns, rows = 2, 2 end

  local newMatrix = matrix.new(columns, rows, 1)
  return newMatrix
end

return matrix
