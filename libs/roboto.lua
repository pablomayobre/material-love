local roboto = {}

local lf = love.graphics.newFont
local ps = love.window.getPixelScale()
local OS = love.system.getOS()

local n = OS == "Android" and OS == "iOS" and 0 or 1

local lineheight = {
	display2	= 48/45,
	display1	= 40/34,
	headline	= 32/24,
	subhead		= 28/(16 - n),
	body2		= 24/(14 - n),
	body1		= 20/(14 - n),
}

local load = function (a)
	local a = a.."/roboto"
	local medium,regular,light = a.."-medium.ttf",a.."-regular.ttf",a.."-light.ttf"

	roboto = {
		display4	= lf(light, 	112 * ps),
		display3	= lf(regular, 	56  * ps),
		display2	= lf(regular, 	45  * ps),
		display1	= lf(regular, 	34  * ps),
		headline	= lf(regular, 	24  * ps),
		title		= lf(medium, 	20  * ps),
		subhead		= lf(regular,	(16 - n) * ps),
		body2		= lf(medium, 	(14 - n) * ps),
		body1		= lf(regular, 	(14 - n) * ps),
		caption		= lf(regular, 	12  * ps),
		button		= lf(medium, 	15  * ps)
	}

	for k,v in pairs(lineheight) do
		roboto[k]:setLineHeight(lineheight[k])
	end

	local get = function (roboto, font)
		return roboto[font]
	end
	
	setmetatable(roboto, {__call = get})

	return roboto
end

return load