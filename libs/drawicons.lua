local draw = {}
return function (a,icons,color)
	draw.font = love.graphics.newFont(a.."/icons.ttf",24*love.window.getPixelScale())

	draw.draw = function (icon,x,y,c,active)
		local c = c or "white"
		local active = (active == nil and true) or active
		local ps = love.window.getPixelScale()

		local font = love.graphics.getFont()
		local r,g,b,a = love.graphics.getColor()

		love.graphics.setFont(draw.font)
		love.graphics.setColor(color.mono(c,active and "icon" or "inactive-icon"))
		love.graphics.printf(icons(icon), x - 14*ps, y - 9*ps, 28 * ps, "center")

		love.graphics.setFont(font)
		love.graphics.setColor(r,g,b,a)
	end

	setmetatable(draw,{__call = function (self,...) return self.draw(...) end})

	return draw
end