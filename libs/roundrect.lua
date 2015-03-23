--Based on Robin's roundrect.lua https://gist.github.com/gvx/9072860 all credits to him
local roundrect = {}

roundrect.get = function (x, y, w, h, xr, yr, pre, t)
	local yr = yr or xr
	local p,pre = {}, pre or xr + yr

	if xr > w * .5 then xr = w * .5 end
	if yr > h * .5 then yr = h * .5 end

	local hp,cos,sin = math.pi * .5, math.cos, math.sin
	local x1, y1, x2, y2 = x + xr, y + yr, x + w - xr, y + h - yr
	local xs = {true,true,false,false}
	local ys = {false,true,true,false}

	for i = 1, 4 do
		if t and not t[i] then
			p[#p + 1] = xs[i] and (w + x) or x
			p[#p + 1] = ys[i] and (h + y) or y
		else
			for j = 0, pre do
				local a = (j / pre + (i - 2))*hp
				p[#p + 1] = (xs[i] and x2 or x1) + xr * cos(a)
				p[#p + 1] = (ys[i] and y2 or y1) + yr * sin(a)
			end
		end
	end

	return p
end

setmetatable(roundrect,{__call = function (s, ...) return s.get(...) end})

return roundrect