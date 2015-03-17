local fab = {}

local load = function (a)
	local lg,ps = love.graphics, love.window.getPixelScale()

	fab.assets = {}

	for i=1,5 do
		fab.assets[i] = lg.newImage( a.."/fab-"..i..".png" )
	end

	fab.draw = function (x,y,r,depth)

		local r = r or 28 * ps
		if r == "mini" then r = 20 * ps end

		local depth = depth or 1

		if not fab.assets[depth] then 
			error("Argument #4 to fab.draw is not a valid depth",2)
		end

		local c = {lg.getColor()}

		lg.push()

			lg.translate(x, y)
			lg.scale(r / 80)

			lg.setColor(255, 255, 255, 255)

			lg.draw(fab.assets[depth], -200, -200)

		lg.pop()

		lg.setColor(c)

		lg.circle("fill", x, y, r)
		lg.circle("line", x, y, r)
	end
	
	setmetatable(fab,{__call = function (fab,...) return fab.draw(...) end})

	return fab
end

return load