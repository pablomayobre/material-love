local draw = {}

return function (a,icons,color)
	local ps = love.window.getPixelScale()
	local lg = love.graphics

	draw.font = lg.newFont(a.."/icons.ttf",24 * ps)

	draw.draw = function (icon,x,y,c,active)
		local c = c or "white"
		local active = (active == nil and true) or active

		local font = lg.getFont()
		local r,g,b,a = lg.getColor()

		lg.setFont(draw.font)
		lg.setColor(color.mono(c, active and "icon" or "inactive-icon"))
		lg.printf(icons(icon), x - 14 * ps, y - 9 * ps, 28 * ps, "center")

		lg.setFont(font)
		lg.setColor(r, g, b, a)
	end

	setmetatable(draw, {__call = function (self, ...) return self.draw(...) end})

	return draw
end