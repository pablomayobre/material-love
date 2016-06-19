local shadow = {}

shadow.metadata = function ()
	return {
		type = "9patch",
		areas = {
			{x =   0, y =   0, w = 100, h = 100, row = 1, col = 1, sx = false, sy = false},
			{x =   0, y = 100, w = 100, h = 200, row = 1, col = 2, sx = false, sy =  true},
			{x =   0, y = 300, w = 100, h = 100, row = 1, col = 3, sx = false, sy = false},
			{x = 100, y =   0, w = 200, h = 100, row = 2, col = 1, sx =  true, sy = false},
			{x = 100, y = 100, w = 200, h = 200, row = 2, col = 2, sx =  true, sy =  true},
			{x = 100, y = 300, w = 200, h = 100, row = 2, col = 3, sx =  true, sy = false},
			{x = 300, y =   0, w = 100, h = 100, row = 3, col = 1, sx = false, sy = false},
			{x = 300, y = 100, w = 100, h = 200, row = 3, col = 2, sx = false, sy =  true},
			{x = 300, y = 300, w = 100, h = 100, row = 3, col = 3, sx = false, sy = false},
		},
		dynamic		= {x = 200, y = 200},
		static		= {x = 200, y = 200},
		dimensions	= {w = 400, h = 400},
		pad			= {100, 100, 100, 100},
	}
end

shadow.images = {}
shadow.patch = {}

local draw = function (x, y, w, h, image)
	return shadow.patch[image or shadow.default]:draw(x, y, w, h, true)
end

shadow.load = function (path, patchy, images, default)
	if type(path) ~= "string" then
		error("bad argument #1 to 'shadow.load' (string expected, got "..type(path)..")", 2)
	else
		shadow.path = path
	end
	
	if not images then images = {1, 2, 3, 4, 5} end
	
	if type(images) ~= "table" then
		error("bad argument #3 to 'shadow.load' (table expected, got "..type(images)..")", 2)
	else
		for _, name in ipairs(images) do
			shadow.images[name] = love.graphics.newImage(path.."-"..name..".png")
		end
	end

	if type(patchy) ~= "table" then
		error("The Patchy module couldnt be found",2)
	else
		for name, image in pairs(shadow.images) do
			shadow.patch[name] = patchy.import(image, shadow.metadata)
		end
	end

	if not default then default = images[1] end

	if not shadow.images[default] then
		error("The default image passed to 'shadow.load' doesnt exist", 2)
	else
		shadow.default = default
	end
	
	shadow.draw = draw
end

return shadow