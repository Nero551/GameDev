local MathHelper = {}

function MathHelper:Sigmoid(n)

   local result = (1 / 1 + math.exp(-n)) 
    return result
end

function MathHelper:Sin(n)
    
end


return MathHelper

