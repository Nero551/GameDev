local StringHelper = {}

function StringHelper:CapitalizeFirstLetters(str)
	return (str:gsub("(%a)([%w_']*)", function(first, rest)
		return first:upper() .. rest:lower()
	end))
end

return StringHelper