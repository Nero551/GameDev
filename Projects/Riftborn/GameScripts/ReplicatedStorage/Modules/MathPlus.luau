local MathPlus = {}

function MathPlus:Sigmoid(n)
    local result = (1 / 1 + math.exp(-n)) 
    return result
end


return MathPlus

