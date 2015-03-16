local fab = {}

local load = function (a)
	fab.assets = {}

	for i=1,5 do
		fab.assets[i]=love.graphics.newImage(a.."/fab-"..i..".png")
	end

	fab.draw = function (x,y,r,depth)
		local r = r or 28 * love.window.getPixelScale()
		if r == "mini" then r = 20 * love.window.getPixelScale() end
		local depth = depth or 1
		if not fab.assets[depth] then error ("Argument #4 to fab.draw is not a valid depth",2) end
		local lg = love.graphics
		local c = {lg.getColor()}
		lg.push()
			lg.translate(x,y)
			lg.scale(r/80)
			lg.setColor(255,255,255,255)
			lg.draw(fab.assets[depth],-200,-200)
		lg.pop()
		lg.setColor(c)
		lg.circle("fill",x,y,r)
		lg.circle("line",x,y,r)
	end

	return fab
end

return load