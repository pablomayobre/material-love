local lf = love.graphics.newFont
return function (a)
	local ro = a.."/roboto"
	local ps = love.window.getPixelScale()
	local m,r,l = ro.."-medium.ttf",ro.."-regular.ttf",ro.."-light.ttf"
	local n = ({["Windows"]=true,["Linux"]=true,["OS X"]=true})[love.system.getOS()] and 1 or 0

	return {
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
end