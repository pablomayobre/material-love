--Based on Robin's roundrect.lua https://gist.github.com/gvx/9072860
--Supports different radius for each corner, does everything in a for loop
--You can easily change the order for the corners!
local roundrect = {}

roundrect.new = function (x, y, width, height, radius, precision)
	local p = {} --Polygon!
	--xs and ys are helper tables that determine the order of the corners (top-left -> clockwise)
	--xs -> true = left, false = right
	--ys -> true = top,  false = bottom
	local xs, ys = {true,false,false,true}, {true,true,false,false}

	if type(radius) ~= "table" then
		radius = {radius or 0, radius or 0, radius or 0, radius or 0}
	end

	for u = 1, 5 do
		local i = ((u - 1) % 4) + 1
		if u < 5 then
			local j, size = i % 4 + 1, i % 2 == 1 and width or height
			--Check if the radius is messed up (the sum of the radius is bigger than width/height)
			--Correct it while keeping proportions
			if radius[i] + radius[j] > size then
				local porcentage = radius[i] / (radius[i] + radius[j])
				radius[i], radius[j] = size * porcentage, size * (1 - porcentage)
			end
		end

		--Add the points to the polygon
		if u > 1 then
			if radius[i] == 0 then
				table.insert(p, xs[i] and x or x + width )
				table.insert(p, ys[i] and y or y + height)
			else
				local precision = precision or radius[i]^2
				for j = 0, precision do
					local add = (xs[i] and ys[i]) and 2 or ((xs[i] and 3 or 2) + (ys[i] and 1 or 2))
					print(add % 4)
					local angle = (j / precision + add) * math.pi / 2
					table.insert(p, (xs[i] and x + radius[i] or x + width  - radius[i]) + radius[i] * math.cos(angle))
					table.insert(p, (ys[i] and y + radius[i] or y + height - radius[i]) + radius[i] * math.sin(angle))
				end
			end
		end
	end

	return p
end

roundrect.polygon = function (mode, polygon)
	if mode == "both" then
		love.graphics.polygon("fill", unpack(polygon))
		love.graphics.polygon("line", unpack(polygon))
	else
		love.graphics.polygon(mode, unpack(polygon))
	end
end

roundrect.draw = function (mode, ...)
	local polygon = roundrect.new(...)
	roundrect.polygon(mode, polygon)
	return polygon
end

return setmetatable(roundrect, { __call = function (s,...) return s.new(...) end })