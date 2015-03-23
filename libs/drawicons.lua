local draw = {}

return function (a,icons,color)
	local ps = love.window.getPixelScale()
	local lg = love.graphics

	draw.font = lg.newFont(a.."/icons.ttf",24 * ps)

	draw.draw = function (icon,x,y,ra,c,active,invert)
		local c = c or "white"
		local active = (active == nil and true) or active

		local sx,sy = 1,1
		local ra = ra or 0

		local invert = invert or "none"

		if invert then
			if invert == "vertical" then
				sy = -1
			elseif invert == "horizontal" then
				sx = -1
			elseif invert == "vertical-horizontal" then
				sx, sy = -1, -1
			elseif invert == "none" then
			else
				error ("Argument #7 to drawicons, an InvertMode expected, got "..invert, 2)
			end
		end

		local font = lg.getFont()
		local r,g,b,a = lg.getColor()

		love.graphics.push()

		love.graphics.translate(x,y)
		love.graphics.scale(sx,sy)
		love.graphics.rotate(ra)

		lg.setFont(draw.font)
		lg.setColor(color.mono(c, active and "icon" or "inactive-icon"))
		lg.printf(icons.get(icon), - 14 * ps, - 11 * ps, 28 * ps, "center")

		love.graphics.pop()

		lg.setFont(font)
		lg.setColor(r, g, b, a)
	end

	setmetatable(draw, {__call = function (self, ...) return self.draw(...) end})

	return draw
end