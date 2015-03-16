local roboto = {}

local lf = love.graphics.newFont
local ps = love.window.getPixelScale()
local OS = love.system.getOS()

local n = OS == "Android" and OS == "iOS" and 0 or 1

local load = function (a)
	local a = a.."/roboto"
	local m,r,l = a.."-medium.ttf",a.."-regular.ttf",a.."-light.ttf"

	roboto = {
		display4	= lf(l,112),
		display3	= lf(r,56),
		display2	= lf(r,45),
		display1	= lf(r,34),
		headline	= lf(r,24),
		title		= lf(m,20),
		subhead		= lf(r,16-n),
		body2		= lf(m,14-n),
		body1		= lf(r,14-n),
		caption		= lf(r,12),
		button		= lf(m,15)
	}
	
	local get = function (roboto,font)
		return roboto[font]
	end
	
	setmetatable(roboto,{__call = get}

	return roboto
end

return load