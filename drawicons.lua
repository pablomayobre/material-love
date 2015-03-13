return function (icons,color)
local iconfont = love.graphics.newFont("material-love/assets/icons.ttf",24*love.window.getPixelScale())

	return function (icon,x,y,c,active)
		local c = c or "white"
		local active = (active == nil and true) or active
		
		local r,g,b,a = love.graphics.getColor()
		love.graphics.setColor(color.monochrome(c,active and "icons" or "inactive-icons"))
		love.graphics.printf(
			icons(icon),
			x-(14*love.window.getPixelScale()),
			y-(9*love.window.getPixelScale()),
			28*love.window.getPixelScale(),
			"center"
		)
		love.graphics.setColor(r,g,b,a)
	end
end