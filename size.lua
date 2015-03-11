local sizes = {
	{name = "xs", w = 0   , active = true },
	{name = "sm", w = 750 , active = false},
	{name = "md", w = 970 , active = false},
	{name = "lg", w = 1170, active = false}
}

local function size()
	local w = love.graphics.getWidth() / love.window.getPixelScale()
	for i = 1, 3 do
		if w < sizes[i+1].w then return sizes[i].name end
	end
	return "lg"
end