local fab = {}

local a = (...):gsub("%.","%/")

fab.assets = {}

for i=1,5 do
	fab.assets["z-depth-"..i]=love.graphics.newImage(a.."-"..i..".png")
end

fab.draw = function (x,y,r,depth)
	local r = r or 56 * love.window.getPixelScale()
	if r == "mini" then r = 40 * love.window.getPixelScale() end
	local depth = depth or "z-depth-1"
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